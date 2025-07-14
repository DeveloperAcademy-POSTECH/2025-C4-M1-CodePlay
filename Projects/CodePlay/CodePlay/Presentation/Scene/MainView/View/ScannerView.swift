//
//  ScannerView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI
import Vision
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode)
    var presentationMode
    @Binding var recognizedText: String

    var onComplete: ((RawText) -> Void)? = nil

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
        var parent: ScannerView
        var fullText: String = ""

        init(_ parent: ScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            let dispatchGroup = DispatchGroup()

            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                recognizeText(in: image)
            }

            dispatchGroup.notify(queue: .main) {
                controller.dismiss(animated: true)
                self.parent.onComplete?(RawText(text: self.fullText))
            }
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
                    let result = recognizedStrings.joined(separator: "\n")
                    self.parent.recognizedText += result + "\n"
                    self.fullText += result + "\n"
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

struct ScannerViewWrapper: View {
    @State private var recognizedText = ""
    let router: MainRouter

    var body: some View {
        ScannerView(
            recognizedText: $recognizedText,
            onComplete: { result in
                router.navigate(to: .loading1(result))
            }
        )
    }
}
