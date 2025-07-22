//
//  ScanPosterView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI
import Vision
import VisionKit

struct ScanPosterView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var wrapper: PosterViewModelWrapper
    @Binding var recognizedText: String

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScanPosterView

        init(_ parent: ScanPosterView) {
            self.parent = parent
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                recognizeText(in: image)
            }
            controller.dismiss(animated: true)
        }

        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            print("Document scanning failed: \(error.localizedDescription)")
        }

        private func recognizeText(in image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            let request = VNRecognizeTextRequest { (request, error) in
                guard
                    let observations = request.results
                        as? [VNRecognizedTextObservation],
                    error == nil
                else { return }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                DispatchQueue.main.async {
                    let fullText = recognizedStrings.joined(separator: "\n")
                    self.parent.recognizedText += fullText
                    self.parent.wrapper.viewModel.scannedText.value = RawText(text: fullText)
                    
                    /// 비동기 처리 후 네비게이션 
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.parent.wrapper.viewModel.shouldNavigateToMakePlaylist.value = true
                    }
                }
            }

            request.recognitionLanguages = ["ko"]
            request.usesLanguageCorrection = true

            let requestHandler = VNImageRequestHandler(
                cgImage: cgImage,
                options: [:]
            )
            do {
                try requestHandler.perform([request])
            } catch {
                print("\(error).")
            }
        }
    }
}
