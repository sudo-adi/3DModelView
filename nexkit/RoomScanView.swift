import SwiftUI
import RealityKit
import RoomPlan
import ARKit

// MARK: - Main Scanning View
struct RoomScanView: View {
    @State private var showScanner = false
    @State private var capturedRoomData: CapturedRoom?
    
    var body: some View {
        VStack {
            Button("Start Room Scan") {
                showScanner = true
            }
            .fullScreenCover(isPresented: $showScanner) {
                RoomScanContainer(capturedRoomData: $capturedRoomData)
            }
            
            if let capturedRoomData = capturedRoomData {
                NavigationLink(destination: Room3DView(capturedRoom: capturedRoomData)) {
                    Text("View 3D Scan")
                }
            }
        }
    }
}

// MARK: - Room Scan Container (UIKit Wrapper)
struct RoomScanContainer: UIViewControllerRepresentable {
    @Binding var capturedRoomData: CapturedRoom?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> RoomCaptureViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RoomCaptureViewController") as! RoomCaptureViewController
        vc.completionHandler = { room in
            capturedRoomData = room
            presentationMode.wrappedValue.dismiss()
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: RoomCaptureViewController, context: Context) {}
}

// MARK: - 3D Room Visualization View
struct Room3DView: View {
    let capturedRoom: CapturedRoom
    @State private var arView = ARView()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(arView: arView, capturedRoom: capturedRoom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Room Scan Visualization")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
                HStack {
                    Label("Wall", systemImage: "square.fill")
                        .foregroundColor(.blue)
                    Label("Door", systemImage: "door.left.hand.open")
                        .foregroundColor(.green)
                    Label("Window", systemImage: "window.vertical.closed")
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            }
            .padding(.bottom, 30)
        }
        .onAppear {
            setupRoomInRealityKit()
        }
    }
    
    private func setupRoomInRealityKit() {
        // Clear previous content
        arView.scene.anchors.removeAll()
        
        // Create an anchor for the room
        let roomAnchor = AnchorEntity()
        arView.scene.addAnchor(roomAnchor)
        
        // Add walls
        for wall in capturedRoom.walls {
            let wallEntity = createSurfaceEntity(
                dimensions: wall.dimensions,
                transform: wall.transform,
                color: .blue,
                label: "Wall"
            )
            roomAnchor.addChild(wallEntity)
        }
        
        // Add doors
        for door in capturedRoom.doors {
            let doorEntity = createSurfaceEntity(
                dimensions: door.dimensions,
                transform: door.transform,
                color: .green,
                label: "Door"
            )
            roomAnchor.addChild(doorEntity)
        }
        
        // Add windows
        for window in capturedRoom.windows {
            let windowEntity = createSurfaceEntity(
                dimensions: window.dimensions,
                transform: window.transform,
                color: .orange,
                label: "Window"
            )
            roomAnchor.addChild(windowEntity)
        }
        
        // Add floors
        for floor in capturedRoom.floors {
            let floorEntity = createSurfaceEntity(
                dimensions: floor.dimensions,
                transform: floor.transform,
                color: .gray,
                label: "Floor"
            )
            roomAnchor.addChild(floorEntity)
        }
        
        // Add objects
        for object in capturedRoom.objects {
            let objectEntity = createObjectEntity(
                dimensions: object.dimensions,
                transform: object.transform,
                category: object.category,
            )
            roomAnchor.addChild(objectEntity)
        }
    }
    
    private func createSurfaceEntity(dimensions: SIMD3<Float>, transform: simd_float4x4, color: UIColor, label: String) -> ModelEntity {
        // Create the visual mesh
        let mesh = MeshResource.generateBox(size: dimensions)
        let material = SimpleMaterial(color: color.withAlphaComponent(0.3), isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.transform = Transform(matrix: transform)
        
        // Add collision (for raycasting)
        entity.generateCollisionShapes(recursive: false)
        
        // Add label
        let textMesh = MeshResource.generateText(
            label,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = [0, dimensions.y/2 + 0.1, 0] // Position above the object
        
        entity.addChild(textEntity)
        
        return entity
    }
    
    private func createObjectEntity(dimensions: SIMD3<Float>, transform: simd_float4x4, category: CapturedRoom.Object.Category, ) -> ModelEntity {
        let color: UIColor
        let label: String
        
        switch category {
        case .table:
            color = .brown
            label = "Table"
        case .chair:
            color = .yellow
            label = "Chair"
        case .sofa:
            color = .purple
            label = "Sofa"
        case .bed:
            color = .red
            label = "Bed"
        case .storage:
            color = .cyan
            label = "Storage"
        case .sink:
            color = .systemTeal
            label = "Sink"
        case .refrigerator:
            color = .white
            label = "Fridge"
        case .stove:
            color = .systemOrange
            label = "Stove"
        case .television:
            color = .black
            label = "TV"
        case .toilet:
            color = .systemBlue
            label = "Toilet"
        @unknown default:
            color = .magenta
            label = "Object"
        }
        
        let entity = createSurfaceEntity(
            dimensions: dimensions,
            transform: transform,
            color: color,
            label: "xyz"
        )
        
        return entity
    }
}

// MARK: - ARView Container
struct ARViewContainer: UIViewRepresentable {
    let arView: ARView
    let capturedRoom: CapturedRoom
    
    func makeUIView(context: Context) -> ARView {
        // Configure ARView
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = []
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// MARK: - RoomCaptureViewController (UIKit)
class RoomCaptureViewController: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {
    var completionHandler: ((CapturedRoom) -> Void)?
    
    private var isScanning = false
    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig = RoomCaptureSession.Configuration()
    private var finalResults: CapturedRoom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoomCaptureView()
        setupNavigationBar()
    }
    
    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        view.insertSubview(roomCaptureView, at: 0)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelScanning)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneScanning)
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    private func startSession() {
        isScanning = true
        roomCaptureView.captureSession.run(configuration: roomCaptureSessionConfig)
    }
    
    private func stopSession() {
        isScanning = false
        roomCaptureView.captureSession.stop()
    }
    
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }
    
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        finalResults = processedResult
    }
    
    @objc private func doneScanning() {
        if isScanning { stopSession() }
        
        if let finalResults = finalResults {
            completionHandler?(finalResults)
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(
                title: "Scan Not Ready",
                message: "Please complete the room scan before proceeding.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func cancelScanning() {
        dismiss(animated: true)
    }
}
