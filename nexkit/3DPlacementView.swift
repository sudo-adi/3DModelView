import SwiftUI
import RealityKit
import Combine

class FurniturePlacementState: ObservableObject {
    @Published var rotationAngle: Float = 0 {
        didSet {
            if rotationAngle > .pi * 2 { rotationAngle -= .pi * 2 }
            else if rotationAngle < 0 { rotationAngle += .pi * 2 }
            UserDefaults.standard.set(rotationAngle, forKey: "furnitureRotationAngle")
        }
    }
    @Published var isFurnitureSelected = false {
        didSet { UserDefaults.standard.set(isFurnitureSelected, forKey: "isFurnitureSelected") }
    }
    @Published var isPlacingMode = false
    @Published var selectedFurnitureType: String = "chair"
    weak var coordinator: RealityKitView.Coordinator?
    init() {
        rotationAngle = UserDefaults.standard.float(forKey: "furnitureRotationAngle")
        isFurnitureSelected = UserDefaults.standard.bool(forKey: "isFurnitureSelected")
    }
}

struct FurnitureView: View {
    @StateObject private var placementState = FurniturePlacementState()
    let furnitureTypes = ["Chair", "Table", "Sofa", "TV", "Bed", "Kitchen", "Dining"]
    
    var body: some View {
        ZStack(alignment: .top) {
            RealityKitView(placementState: placementState)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(furnitureTypes, id: \.self) { furnitureType in
                            FurnitureButton(
                                furnitureType: furnitureType,
                                isSelected: placementState.isPlacingMode && placementState.selectedFurnitureType == furnitureType.lowercased()
                            ) {
                                placementState.isPlacingMode = true
                                placementState.selectedFurnitureType = furnitureType.lowercased()
                            }
                            .frame(width: 80, height: 60)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                }
                .frame(height: 80)
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                
                Spacer()
            }
            
            if placementState.isFurnitureSelected {
                VStack {
                    Spacer()
                    Slider(value: $placementState.rotationAngle, in: 0...(.pi * 2), step: 0.01)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        placementState.coordinator?.deleteSelectedFurniture()
                    }) {
                        Text("Delete")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            
            if placementState.isPlacingMode {
                Text("Tap on the floor to place \(placementState.selectedFurnitureType)")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .transition(.opacity)
            }
        }
    }
}

struct FurnitureButton: View {
    let furnitureType: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.white)
                    .shadow(radius: 3)
                
                Text(furnitureType)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .black)
                    .padding(8)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct RealityKitView: UIViewRepresentable {
    @ObservedObject var placementState: FurniturePlacementState
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.white)
        
        let scene = createScene()
        arView.scene.anchors.append(scene)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotation(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        
        [tapGesture, panGesture, rotationGesture, pinchGesture].forEach {
            arView.addGestureRecognizer($0)
        }
        
        context.coordinator.arView = arView
        context.coordinator.rootAnchor = scene
        context.coordinator.placementState = placementState
        placementState.coordinator = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let furniture = context.coordinator.selectedEntity {
            furniture.transform.rotation = simd_quatf(angle: placementState.rotationAngle, axis: [0, 1, 0])
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    private func createScene() -> AnchorEntity {
        let rootAnchor = AnchorEntity()
        
        let floorSize: Float = 5.0
        let floorThickness: Float = 0.0002
        
        let floorEntity = ModelEntity(
            mesh: .generateBox(width: floorSize, height: floorThickness, depth: floorSize),
            materials: [SimpleMaterial(color: .lightGray, isMetallic: false)]
        )
        floorEntity.name = "floor"
        floorEntity.position.y = -floorThickness/2
        floorEntity.collision = CollisionComponent(shapes: [.generateBox(width: floorSize, height: floorThickness, depth: floorSize)])
        rootAnchor.addChild(floorEntity)
        
        let camera = PerspectiveCamera()
        camera.name = "mainCamera"
        camera.position = [0.4, 0.4, 0.4]
        camera.look(at: [0, 0, 0], from: camera.position, relativeTo: rootAnchor)
        rootAnchor.addChild(camera)
        
        return rootAnchor
    }
    
    class Coordinator: NSObject {
        weak var placementState: FurniturePlacementState?
        weak var arView: ARView?
        weak var rootAnchor: AnchorEntity?
        
        var selectedEntity: ModelEntity? {
            didSet {
                placementState?.isFurnitureSelected = selectedEntity != nil
                
                if selectedEntity == nil {
                    if let oldValue = oldValue {
                        if var material = oldValue.model?.materials.first as? SimpleMaterial {
                            material.color.tint = .white
                            oldValue.model?.materials = [material]
                        }
                    }
                } else {
                    if let selectedEntity = selectedEntity {
                        let currentRotation = selectedEntity.transform.rotation
                        let angle = currentRotation.angle
                        placementState?.rotationAngle = angle
                        
                        if var material = selectedEntity.model?.materials.first as? SimpleMaterial {
                            material.color.tint = .yellow
                            selectedEntity.model?.materials = [material]
                        }
                    }
                }
            }
        }
        
        func deleteSelectedFurniture() {
            guard let selectedEntity = selectedEntity else { return }
            selectedEntity.removeFromParent()
            self.selectedEntity = nil
            placementState?.isFurnitureSelected = false
        }
    
        private var initialCameraPosition: SIMD3<Float>?
        private var initialPinchScale: CGFloat = 1.0
        private var initialPanLocation: CGPoint?
        private var initialCameraTransform: Transform?
        private var initialEntityPosition: SIMD3<Float>?
        private var furnitureCounter = 1
        private let floorSize: SIMD2<Float> = [5, 5]
        private var cancellables = Set<AnyCancellable>()
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            let location = gesture.location(in: arView)
            
            if location.y > arView.bounds.height * 0.8 { return }
            
            if placementState?.isPlacingMode == true {
                handlePlacementModeTap(at: location)
                return
            }
            
            handleSelectionTap(at: location)
        }
        
        private func handlePlacementModeTap(at location: CGPoint) {
            guard let arView = arView,
                  let rootAnchor = rootAnchor,
                  let floorEntity = rootAnchor.findEntity(named: "floor") as? ModelEntity,
                  let ray = arView.ray(through: location),
                  let furnitureType = placementState?.selectedFurnitureType else { return }
            
            let planeNormal: SIMD3<Float> = [0, 1, 0]
            let planePoint: SIMD3<Float> = [0, 0.0001, 0]
            
            let denominator = dot(ray.direction, planeNormal)
            guard abs(denominator) > 0.00001 else { return }
            
            let t = dot(planePoint - ray.origin, planeNormal) / denominator
            guard t > 0 else { return }
            
            let worldPos = ray.origin + t * ray.direction
            let localPos = floorEntity.transformMatrix(relativeTo: nil).inverse * [worldPos.x, worldPos.y, worldPos.z, 1]
            
            let halfFloorSize = floorSize / 2
            let furnitureSize: Float = 0.005
            
            let minX = -halfFloorSize.x + furnitureSize
            let maxX = halfFloorSize.x - furnitureSize
            let minZ = -halfFloorSize.y + furnitureSize
            let maxZ = halfFloorSize.y - furnitureSize
            
            let constrainedX = min(max(localPos.x, minX), maxX)
            let constrainedZ = min(max(localPos.z, minZ), maxZ)
            
            loadFurnitureModel(type: furnitureType) { [weak self] modelEntity in
                guard let self = self else { return }
                
                let boundingBox = modelEntity.visualBounds(relativeTo: nil)
                let baseOffset = boundingBox.min.y
                
                modelEntity.position = [constrainedX, -baseOffset, constrainedZ]
                modelEntity.name = "furniture\(self.furnitureCounter)"
                modelEntity.generateCollisionShapes(recursive: true)
                
                self.furnitureCounter += 1
                
                floorEntity.addChild(modelEntity)
                
                self.selectedEntity = modelEntity
                self.placementState?.isPlacingMode = false
            }
        }
        
        private func loadFurnitureModel(type: String, completion: @escaping (ModelEntity) -> Void) {
            let modelName: String
            switch type {
            case "chair": modelName = "Chair"
            case "table": modelName = "Table"
            case "sofa": modelName = "Sofa"
            case "tv": modelName = "TV"
            case "bed": modelName = "Bed"
            case "kitchen": modelName = "KitchenTop"
            case "dining": modelName = "Dining"
            default: modelName = "Chair"
            }
            
            let fallbackModel = createFallbackModel(type: type)
            
            guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") else {
                completion(fallbackModel)
                return
            }
            
            Entity.loadModelAsync(contentsOf: modelURL)
                .sink(receiveCompletion: { _ in
                    completion(fallbackModel)
                }, receiveValue: { [weak self] entity in
                    guard let self = self, let modelEntity = entity as? ModelEntity else {
                        completion(fallbackModel)
                        return
                    }
                    
                    let boundingBox = modelEntity.visualBounds(relativeTo: nil)
                    let size = max(boundingBox.max.x - boundingBox.min.x, boundingBox.max.z - boundingBox.min.z)
                    let scale: Float = 0.005 / size
                    modelEntity.scale = [scale, scale, scale]
                    
                    if modelEntity.model?.materials.isEmpty ?? true {
                        var material = SimpleMaterial()
                        material.color = .init(tint: .white, texture: nil)
                        modelEntity.model?.materials = [material]
                    }
                    
                    DispatchQueue.main.async {
                        completion(modelEntity)
                    }
                })
                .store(in: &cancellables)
        }
        
        private func createFallbackModel(type: String) -> ModelEntity {
            let color: UIColor
            let mesh: MeshResource
            
            switch type {
            case "chair":
                color = .brown
                mesh = .generateBox(size: [0.005, 0.008, 0.005])
            case "table":
                color = .darkGray
                mesh = .generateBox(size: [0.01, 0.008, 0.01])
            case "sofa":
                color = .red
                mesh = .generateBox(size: [0.015, 0.006, 0.007])
            case "tv":
                color = .black
                mesh = .generateBox(size: [0.012, 0.008, 0.001])
            case "bed":
                color = .blue
                mesh = .generateBox(size: [0.02, 0.006, 0.015])
            case "kitchen":
                color = .white
                mesh = .generateBox(size: [0.02, 0.008, 0.01])
            case "dining":
                color = .green
                mesh = .generateBox(size: [0.015, 0.008, 0.015])
            default:
                color = .yellow
                mesh = .generateSphere(radius: 0.003)
            }
            
            var material = SimpleMaterial()
            material.color = .init(tint: color, texture: nil)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            return entity
        }
        
        private func handleSelectionTap(at location: CGPoint) {
            guard let arView = arView else { return }
            
            if let entity = arView.entity(at: location) as? ModelEntity,
               entity.name.hasPrefix("furniture") {
                toggleSelection(for: entity)
            } else {
                deselectCurrentFurniture()
            }
        }
        
        private func toggleSelection(for entity: ModelEntity) {
            if selectedEntity == entity {
                deselectCurrentFurniture()
            } else {
                selectNewFurniture(entity)
            }
        }
        
        private func selectNewFurniture(_ entity: ModelEntity) {
            deselectCurrentFurniture()
            selectedEntity = entity
            
            if var material = entity.model?.materials.first as? SimpleMaterial {
                material.color.tint = .yellow
                entity.model?.materials = [material]
            }
        }
        
        private func deselectCurrentFurniture() {
            guard let selectedEntity = selectedEntity else { return }
            
            if var material = selectedEntity.model?.materials.first as? SimpleMaterial {
                material.color.tint = .white
                selectedEntity.model?.materials = [material]
            }
            
            self.selectedEntity = nil
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let arView = arView else { return }
            
            let location = gesture.location(in: arView)
            
            switch gesture.state {
            case .began:
                if let entity = arView.entity(at: location) as? ModelEntity,
                   entity.name.hasPrefix("furniture") {
                    if selectedEntity != entity {
                        selectNewFurniture(entity)
                    }
                    initialEntityPosition = selectedEntity?.position
                } else {
                    deselectCurrentFurniture()
                    initialPanLocation = location
                    if let rootAnchor = rootAnchor,
                       let camera = rootAnchor.findEntity(named: "mainCamera") as? PerspectiveCamera {
                        initialCameraTransform = camera.transform
                    }
                }
                
            case .changed:
                if let selectedEntity = selectedEntity {
                    guard let floor = selectedEntity.parent,
                          let ray = arView.ray(through: location),
                          let initialPos = initialEntityPosition else { return }
                    
                    let planeNormal: SIMD3<Float> = [0, 1, 0]
                    let denominator = dot(ray.direction, planeNormal)
                    guard abs(denominator) > 0.00001 else { return }
                    
                    let t = dot(-ray.origin, planeNormal) / denominator
                    guard t > 0 else { return }
                    
                    let worldPos = ray.origin + t * ray.direction
                    let localPos = floor.transformMatrix(relativeTo: nil) * [worldPos.x, worldPos.y, worldPos.z, 1]
                    
                    let halfFloorSize = floorSize / 2
                    let boundingBox = selectedEntity.visualBounds(relativeTo: nil)
                    let furnitureSize = max(boundingBox.max.x - boundingBox.min.x, boundingBox.max.z - boundingBox.min.z)
                    
                    let minX = -halfFloorSize.x + furnitureSize/2
                    let maxX = halfFloorSize.x - furnitureSize/2
                    let minZ = -halfFloorSize.y + furnitureSize/2
                    let maxZ = halfFloorSize.y - furnitureSize/2
                    
                    let constrainedX = min(max(localPos.x, minX), maxX)
                    let constrainedZ = min(max(localPos.z, minZ), maxZ)
                    
                    selectedEntity.position = [constrainedX, initialPos.y, constrainedZ]
                } else {
                    guard let initialLocation = initialPanLocation,
                          let initialTransform = initialCameraTransform,
                          let rootAnchor = rootAnchor,
                          let camera = rootAnchor.findEntity(named: "mainCamera") as? PerspectiveCamera else { return }
                    
                    let currentLocation = location
                    let delta = CGPoint(x: currentLocation.x - initialLocation.x,
                                        y: currentLocation.y - initialLocation.y)
                    
                    let rotationSensitivity: Float = 0.005
                    let horizontalAngle = -Float(delta.x) * rotationSensitivity
                    let verticalAngle = -Float(delta.y) * rotationSensitivity
                    
                    let relativePosition = initialTransform.translation - [0, 0, 0]
                    let horizontalRotation = simd_quatf(angle: horizontalAngle, axis: [0, 1, 0])
                    let newHorizontalPosition = horizontalRotation.act(relativePosition)
                    
                    let cameraRotation = initialTransform.rotation
                    let cameraRight = cameraRotation.act([1, 0, 0])
                    let verticalRotation = simd_quatf(angle: verticalAngle, axis: cameraRight)
                    let newPosition = verticalRotation.act(newHorizontalPosition)
                    
                    camera.transform.translation = newPosition + [0, 0, 0]
                    camera.look(at: [0, 0, 0], from: camera.position(relativeTo: nil), relativeTo: rootAnchor)
                }
                
            case .ended, .cancelled:
                initialPanLocation = nil
                initialCameraTransform = nil
                initialEntityPosition = nil
            default: break
            }
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let selectedEntity = selectedEntity else { return }
            
            if gesture.state == .changed {
                let rotation = Float(gesture.rotation)
                selectedEntity.transform.rotation *= simd_quatf(angle: rotation, axis: [0, 1, 0])
                placementState?.rotationAngle = selectedEntity.transform.rotation.angle
                gesture.rotation = 0
            }
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let rootAnchor = rootAnchor,
                  let camera = rootAnchor.findEntity(named: "mainCamera") as? PerspectiveCamera else { return }
            
            switch gesture.state {
            case .began:
                initialCameraPosition = camera.position
                initialPinchScale = gesture.scale
            case .changed:
                guard let initialPosition = initialCameraPosition else { return }
                let zoomFactor = Float(gesture.scale / initialPinchScale)
                let direction = normalize(initialPosition)
                let newDistance = length(initialPosition) / zoomFactor
                camera.position = direction * newDistance
                camera.look(at: [0, 0, 0], from: camera.position(relativeTo: nil), relativeTo: rootAnchor)
            case .ended, .cancelled:
                initialCameraPosition = nil
            default: break
            }
        }
    }
}

struct FurnitureView_Previews: PreviewProvider {
    static var previews: some View {
        FurnitureView()
    }
}
