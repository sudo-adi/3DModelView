import SwiftUI
import RealityKit

struct RoomViewer: View {
    @State private var roomModel: RoomModel?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // 3D View
            if let roomModel = roomModel {
                RoomARView(roomModel: roomModel)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Loading/Error state
            if isLoading || errorMessage != nil {
                VStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(2)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
            }
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Create RoomData directly from the provided JSON
        let sampleData = RoomData(
            walls: [
                RoomData.Surface(
                    dimensions: ["width": 0.59943825, "height": 2.8319998, "thickness": 0],
                    transform: [0.58384776, 0, -0.81186324, 0, 0, 1, 0, 0, 0.81186324, 0, 0.58384776, 0, -6.5146885, -0.07333303, -1.5274044, 0.99999994]
                ),
                RoomData.Surface(
                    dimensions: ["width": 0.37769136, "height": 2.8319998, "thickness": 0],
                    transform: [-0.8118631, 0, -0.5838479, 0, 0, 1, 0, 0, 0.5838479, 0, -0.8118631, 0, -6.4930143, -0.07333303, -1.8809927, 0.99999994]
                ),
                RoomData.Surface(
                    dimensions: ["width": 0.56796247, "height": 2.8319998, "thickness": 0],
                    transform: [0.5838476, 0, -0.81186324, 0, 0, 1, 0, 0, 0.81186324, 0, 0.5838476, 0, -7.9479027, -0.07333303, 0.28724205, 0.99999994]
                ),
                RoomData.Surface(
                    dimensions: ["width": 0.4565017, "height": 2.8319998, "thickness": 0],
                    transform: [-0.8118632, 0, -0.5838476, 0, 0, 1, 0, 0, 0.58384764, 0, -0.8118633, 0, -7.9674096, -0.07333303, -0.07657558, 0.99999994]
                ),
                RoomData.Surface(
                    dimensions: ["width": 0.34377488, "height": 3.1799998, "thickness": 0],
                    transform: [0.5838491, 0, -0.8118623, 0, 0, 0.99999994, 0, 0, 0.8118622, 0, 0.583849, 0, -8.127935, 0.10066699, -4.077535, 0.99999994]
                ),
                RoomData.Surface(
                    dimensions: ["width": 11.300292, "height": 2.8319998, "thickness": 0],
                    transform: [-0.64263487, 0, 0.76617247, 0, 0, 1, 0, 0, -0.7661725, 0, -0.6426349, 0, -0.2148734, -0.07333303, 2.2548747, 0.99999994]
                )
            ],
            doors: [
                RoomData.Surface(
                    dimensions: ["width": 1.866566, "height": 2.1742706, "thickness": 0],
                    transform: [-0.6426349, 0, 0.7661725, 0, 0, 1, 0, 0, -0.76617247, 0, -0.6426349, 0, 0.9360179, -0.40219766, 0.88274074, 0.99999994]
                )
            ],
            windows: [],
            openings: [],
            floors: [
                RoomData.Surface(
                    dimensions: ["width": 11.956164, "height": 10.194772, "thickness": 0],
                    transform: [-0.6358802, 0, 0.77178776, 0, 0.77178776, 0, 0.63588023, 0, 0, 0.99999994, 0, 0, -4.319335, -1.489333, -0.70162904, 0.99999994]
                )
            ],
            objects: [
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.5029304, "height": 1.0555935, "length": 0.5757145],
                    confidence: "low",
                    transform: [-0.5838477, 0, 0.8118632, 0, 0, 1, 0, 0, -0.8118632, 0, -0.5838477, 0, -8.031155, -0.9615361, -1.3944224, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.49668324, "height": 0.9699724, "length": 0.57934576],
                    confidence: "low",
                    transform: [0.58356696, 0, -0.81206495, 0, 0, 1, 0, 0, 0.81206495, 0, 0.58356696, 0, -6.636181, -1.0043468, 2.4246001, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.5029304, "height": 1.0555935, "length": 0.57571423],
                    confidence: "low",
                    transform: [0.8118639, 0, 0.5838467, 0, 0, 1, 0, 0, -0.5838467, 0, 0.8118639, 0, -8.200504, -0.96153635, -2.3748372, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.5226748, "height": 0.86747485, "length": 0.60906976],
                    confidence: "low",
                    transform: [0.6426339, 0, -0.7661734, 0, 0, 0.99999994, 0, 0, 0.76617336, 0, 0.64263386, 0, -3.4226334, -1.0555956, 2.7269082, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.5483856, "height": 0.9995052, "length": 0.6553189],
                    confidence: "medium",
                    transform: [0.58384717, 0, -0.8118636, 0, 0, 1, 0, 0, 0.8118636, 0, 0.58384717, 0, -6.7773085, -0.98958033, -0.02074525, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.5483857, "height": 0.9995051, "length": 0.6553188],
                    confidence: "medium",
                    transform: [0.81186384, 0, 0.5838468, 0, 0, 1, 0, 0, -0.5838468, 0, 0.81186384, 0, -5.80867, -0.98958033, -0.20707557, 0.99999994]
                ),
                RoomData.Object(
                    category: "table",
                    dimensions: ["width": 1.4614089, "height": 0.7728283, "length": 1.4280217],
                    confidence: "high",
                    transform: [-0.64263487, 0, 0.7661726, 0, 0, 1, 0, 0, -0.7661725, 0, -0.64263487, 0, -2.9455767, -1.102919, 3.1270452, 0.99999994]
                ),
                RoomData.Object(
                    category: "table",
                    dimensions: ["width": 1.8457034, "height": 0.79437226, "length": 1.0427397],
                    confidence: "high",
                    transform: [-0.8118632, 0, -0.58384764, 0, 0, 0.99999994, 0, 0, 0.5838476, 0, -0.8118631, 0, -5.957504, -1.0921469, 2.9126675, 0.99999994]
                ),
                RoomData.Object(
                    category: "table",
                    dimensions: ["width": 1.5925167, "height": 0.86147994, "length": 1.5668913],
                    confidence: "high",
                    transform: [0.8118633, 0, 0.5838476, 0, 0, 0.99999994, 0, 0, -0.5838475, 0, 0.81186324, 0, -8.607498, -1.058593, -1.8088968, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.52267474, "height": 0.86747485, "length": 0.60907006],
                    confidence: "medium",
                    transform: [0.7661721, 0, 0.64263535, 0, 0, 0.99999994, 0, 0, -0.64263535, 0, 0.76617205, 0, -2.5347118, -1.0555956, 2.6371973, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.5483856, "height": 0.9995051, "length": 0.6553189],
                    confidence: "low",
                    transform: [-0.5838471, 0, 0.81186366, 0, 0, 1, 0, 0, -0.81186366, 0, -0.58384717, 0, -5.6770487, -0.98958033, 0.7705003, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.5483857, "height": 0.99950516, "length": 0.6553192],
                    confidence: "low",
                    transform: [-0.81186306, 0, -0.58384794, 0, 0, 1, 0, 0, 0.58384794, 0, -0.81186306, 0, -6.645686, -0.98958033, 0.95683014, 0.99999994]
                ),
                RoomData.Object(
                    category: "table",
                    dimensions: ["width": 1.34082, "height": 0.7911698, "length": 0.7600091],
                    confidence: "low",
                    transform: [0.5838474, 0, -0.8118635, 0, 0, 0.99999994, 0, 0, 0.8118634, 0, 0.58384734, 0, -8.341161, -1.0937481, 2.804056, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.49668387, "height": 0.96997243, "length": 0.5793455],
                    confidence: "low",
                    transform: [0.81186336, 0, 0.5838475, 0, 0, 0.99999994, 0, 0, -0.58384746, 0, 0.8118633, 0, -5.3292265, -1.0043468, 2.8293417, 0.99999994]
                ),
                RoomData.Object(
                    category: "table",
                    dimensions: ["width": 1.6302174, "height": 0.8286499, "length": 1.5518229],
                    confidence: "high",
                    transform: [0.58384705, 0, -0.81186366, 0, 0, 0.99999994, 0, 0, 0.8118636, 0, 0.58384705, 0, -6.227178, -1.075008, 0.3748775, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.47387716, "height": 0.8907763, "length": 0.5147705],
                    confidence: "low",
                    transform: [0.5838474, 0, -0.8118634, 0, 0, 0.99999994, 0, 0, 0.81186336, 0, 0.58384734, 0, -8.586985, -1.0439448, 2.6272736, 0.99999994]
                ),
                RoomData.Object(
                    category: "chair",
                    dimensions: ["width": 0.4966841, "height": 0.9699723, "length": 0.57934564],
                    confidence: "medium",
                    transform: [0.81186396, 0, 0.5838467, 0, 0, 1.0000001, 0, 0, -0.58384675, 0, 0.8118641, 0, -6.0784554, -1.0043468, 2.2905366, 0.99999994]
                )
            ]
        )
        
        DispatchQueue.main.async {
            self.roomModel = RoomModel(from: sampleData)
            self.isLoading = false
        }
    }
}

struct RoomARView: UIViewRepresentable {
    let roomModel: RoomModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Set white background
        arView.environment.background = .color(.white)
        
        // Create anchor and add to scene
        let anchor = AnchorEntity(world: [0, 0, 0])
        arView.scene.addAnchor(anchor)
        
        // Add room components to anchor
        roomModel.addToScene(anchor: anchor)
        
        // Configure lighting
        setupLighting(in: arView)
        
        // Setup camera
        setupCamera(in: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func setupLighting(in arView: ARView) {
        // Main directional light
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 1500
        directionalLight.light.color = .init(white: 1.0, alpha: 1.0)
        directionalLight.shadow = DirectionalLightComponent.Shadow(
            maximumDistance: 20,
            depthBias: 5.0
        )
        
        // Secondary fill light
        let fillLight = DirectionalLight()
        fillLight.light.intensity = 500
        fillLight.light.color = .init(white: 0.8, alpha: 1.0)
        
        // Position lights
        let lightAnchor = AnchorEntity(world: .zero)
        directionalLight.look(at: [0, 0, 0], from: [3, 5, 3], relativeTo: nil)
        fillLight.look(at: [0, 0, 0], from: [-2, 4, -2], relativeTo: nil)
        
        lightAnchor.addChild(directionalLight)
        lightAnchor.addChild(fillLight)
        arView.scene.addAnchor(lightAnchor)
    }
    
    private func setupCamera(in arView: ARView) {
        // Configure for isometric view
        let camera = PerspectiveCamera()
        camera.camera.fieldOfViewInDegrees = 60
        
        // Isometric position and rotation
        let cameraPosition = SIMD3<Float>(10, 10, 10) // Equal distances for isometric view
        let lookAtPosition = SIMD3<Float>(-5, 0, 0) // Adjusted center point based on room data
        
        let cameraAnchor = AnchorEntity(world: cameraPosition)
        cameraAnchor.addChild(camera)
        arView.scene.addAnchor(cameraAnchor)
        
        arView.cameraMode = .nonAR
        camera.look(at: lookAtPosition, from: cameraPosition, relativeTo: nil)
        
        // Set white background
        arView.environment.background = .color(.white)
    }
}

// MARK: - Data Models

struct RoomData {
    struct Surface {
        let dimensions: [String: Float]
        let transform: [Float]
    }
    
    struct Object {
        let category: String
        let dimensions: [String: Float]
        let confidence: String
        let transform: [Float]
    }
    
    let walls: [Surface]
    let doors: [Surface]
    let windows: [Surface]
    let openings: [Surface]
    let floors: [Surface]
    let objects: [Object]
}

class RoomModel {
    private let roomData: RoomData
    
    init(from roomData: RoomData) {
        self.roomData = roomData
    }
    
    func addToScene(anchor: AnchorEntity) {
        // Add floors first (as they should be at the bottom)
        for floor in roomData.floors {
            addFloor(floor, anchor: anchor)
        }
        
        // Add walls
        for wall in roomData.walls {
            addWall(wall, anchor: anchor)
        }
        
        // Add doors
        for door in roomData.doors {
            addDoor(door, anchor: anchor)
        }
        
        // Add objects
        for object in roomData.objects {
            addObject(object, anchor: anchor)
        }
    }
    
    private func addFloor(_ floor: RoomData.Surface, anchor: AnchorEntity) {
        guard let width = floor.dimensions["width"],
              let length = floor.dimensions["height"], // Using height as length for floor
              let thickness = floor.dimensions["thickness"] else { return }
        
        // Floor should be thin but large in area
        let actualThickness = max(thickness, 0.05)
        
        // For floors, width and height (length) represent the horizontal dimensions
        let size = SIMD3<Float>(width, actualThickness, length)
        let mesh = MeshResource.generateBox(size: size)
        
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 1.0))
        material.metallic = 0.0
        material.roughness = 0.3
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Apply transform from JSON
        let transform = float4x4(floor.transform)
        entity.transform = Transform(matrix: transform)
        
        anchor.addChild(entity)
    }
    
    private func addWall(_ wall: RoomData.Surface, anchor: AnchorEntity) {
        guard let width = wall.dimensions["width"],
              let height = wall.dimensions["height"],
              let thickness = wall.dimensions["thickness"] else { return }
        
        // Use minimum thickness if zero
        let actualThickness = max(thickness, 0.05)
        
        // Wall dimensions: width is length along wall, height is up, thickness is depth
        let size = SIMD3<Float>(actualThickness, height, width)
        let mesh = MeshResource.generateBox(size: size)
        
        var material = SimpleMaterial()
        material.color = .init(tint: .lightGray)
        material.metallic = 0.0
        material.roughness = 0.5
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Apply transform from JSON
        let transform = float4x4(wall.transform)
        entity.transform = Transform(matrix: transform)
        
        anchor.addChild(entity)
    }
    
    private func addDoor(_ door: RoomData.Surface, anchor: AnchorEntity) {
        guard let width = door.dimensions["width"],
              let height = door.dimensions["height"],
              let thickness = door.dimensions["thickness"] else { return }
        
        // Use minimum thickness if zero
        let actualThickness = max(thickness, 0.05)
        
        // Door dimensions
        let size = SIMD3<Float>(actualThickness, height, width)
        let mesh = MeshResource.generateBox(size: size)
        
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor.brown)
        material.metallic = 0.0
        material.roughness = 0.7
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Apply transform from JSON
        let transform = float4x4(door.transform)
        entity.transform = Transform(matrix: transform)
        
        anchor.addChild(entity)
    }
    
    private func addObject(_ object: RoomData.Object, anchor: AnchorEntity) {
        guard let width = object.dimensions["width"],
              let height = object.dimensions["height"],
              let length = object.dimensions["length"] else { return }
        
        let size = SIMD3<Float>(width, height, length)
        let mesh = MeshResource.generateBox(size: size)
        
        // Assign different colors based on object category
        let color: UIColor
        switch object.category.lowercased() {
        case "table":
            color = UIColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1.0)
        case "chair":
            color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        case "sofa", "couch":
            color = UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1.0)
        case "bed":
            color = UIColor(red: 0.9, green: 0.8, blue: 0.7, alpha: 1.0)
        default:
            color = .systemGray
        }
        
        var material = SimpleMaterial()
        material.color = .init(tint: color)
        material.metallic = 0.0
        material.roughness = 0.7
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Apply transform from JSON
        let transform = float4x4(object.transform)
        entity.transform = Transform(matrix: transform)
        
        // Add physics body for interaction (optional)
        entity.generateCollisionShapes(recursive: true)
        
        anchor.addChild(entity)
    }
}

extension float4x4 {
    init(_ values: [Float]) {
        self.init(
            SIMD4<Float>(values[0], values[1], values[2], values[3]),
            SIMD4<Float>(values[4], values[5], values[6], values[7]),
            SIMD4<Float>(values[8], values[9], values[10], values[11]),
            SIMD4<Float>(values[12], values[13], values[14], values[15])
        )
    }
}

struct RoomViewer_Previews: PreviewProvider {
    static var previews: some View {
        RoomViewer()
    }
}
