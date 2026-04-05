import SwiftUI
import UIKit
import VisionKit

struct VaccineDocumentScannerView: UIViewControllerRepresentable {
    let onCancel: () -> Void
    let onScan: ([UIImage]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCancel: onCancel, onScan: onScan)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onCancel: () -> Void
        let onScan: ([UIImage]) -> Void

        init(onCancel: @escaping () -> Void, onScan: @escaping ([UIImage]) -> Void) {
            self.onCancel = onCancel
            self.onScan = onScan
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            onCancel()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
            onCancel()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let pages = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
            onScan(pages)
        }
    }
}
