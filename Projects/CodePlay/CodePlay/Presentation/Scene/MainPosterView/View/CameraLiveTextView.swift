//
//  CameraLiveTextView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/24/25.
//

import SwiftUI
import AVFoundation
import Vision
import UIKit

struct CameraLiveTextView: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    @Binding var isPresented: Bool
    @EnvironmentObject var wrapper: PosterViewModelWrapper
    
    func makeUIViewController(context: Context) -> CameraLiveTextViewController {
        let controller = CameraLiveTextViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraLiveTextViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraLiveTextDelegate {
        let parent: CameraLiveTextView
        
        init(_ parent: CameraLiveTextView) {
            self.parent = parent
        }
        
        func didSelectRegion(with text: String) {
            DispatchQueue.main.async {
                self.parent.recognizedText = text
                self.parent.wrapper.viewModel.scannedText.value = RawText(text: text)
                
                // 선택 완료 후 자동으로 다음 화면으로
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.parent.wrapper.viewModel.shouldNavigateToMakePlaylist.value = true
                    self.parent.isPresented = false
                }
            }
        }
        
        func didDismiss() {
            parent.isPresented = false
        }
    }
}

protocol CameraLiveTextDelegate: AnyObject {
    func didSelectRegion(with text: String)
    func didDismiss()
}

class CameraLiveTextViewController: UIViewController {
    weak var delegate: CameraLiveTextDelegate?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var textRecognitionRequest: VNRecognizeTextRequest!
    
    private var regionSelectionView: RegionSelectionView!
    private var isRegionSelected = false
    private var selectedRegion: CGRect = .zero
    private var recognizedTextElements: [TextElement] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupTextRecognition()
        setupRegionSelection()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("카메라를 사용할 수 없습니다.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
        } catch {
            print("카메라 설정 오류: \(error)")
        }
    }
    
    private func setupTextRecognition() {
        textRecognitionRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self,
                  let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else { return }
            
            var textElements: [TextElement] = []
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                
                let boundingBox = observation.boundingBox
                let convertedRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: boundingBox)
                
                let textElement = TextElement(
                    text: topCandidate.string,
                    boundingBox: convertedRect,
                    confidence: topCandidate.confidence
                )
                textElements.append(textElement)
            }
            
            DispatchQueue.main.async {
                self.recognizedTextElements = textElements
                if self.isRegionSelected {
                    self.showTextInSelectedRegion()
                }
            }
        }
        
        textRecognitionRequest.recognitionLanguages = ["en", "ko"]
        textRecognitionRequest.usesLanguageCorrection = true
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.minimumTextHeight = 0.03 // 작은 텍스트도 인식하도록 설정
        textRecognitionRequest.automaticallyDetectsLanguage = true
    }
    
    private func setupRegionSelection() {
        regionSelectionView = RegionSelectionView(frame: view.bounds)
        regionSelectionView.delegate = self
        view.addSubview(regionSelectionView)
    }
    
    private func setupUI() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // TODO: 하단 안내 텍스트 - 폰트 사이즈 작게 하기
        let instructionLabel = UILabel()
        instructionLabel.text = "텍스트를 드래그하는 동안 움직이지 마세요."
        instructionLabel.textColor = .white
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        instructionLabel.textAlignment = .center
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.clipsToBounds = true
        
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.heightAnchor.constraint(equalToConstant: 32),
            instructionLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }
    
    private func showTextInSelectedRegion() {
        // 선택된 영역 내의 텍스트만 필터링
        let textsInRegion = recognizedTextElements.filter { textElement in
            return selectedRegion.intersects(textElement.boundingBox)
        }
        
        // 영역 내 텍스트들을 위치순으로 정렬하고 합치기
        let sortedTexts = textsInRegion.sorted { first, second in
            if abs(first.boundingBox.minY - second.boundingBox.minY) < 20 {
                return first.boundingBox.minX < second.boundingBox.minX
            } else {
                return first.boundingBox.minY < second.boundingBox.minY
            }
        }
        
        let combinedText = sortedTexts.map { $0.text }.joined(separator: " ")
        
        if !combinedText.isEmpty {
            // 햅틱 피드백
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // 텍스트 전달
            delegate?.didSelectRegion(with: combinedText)
            print("combinedText:\(combinedText)")
        }
    }
    
    @objc private func closeButtonTapped() {
        delegate?.didDismiss()
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
        regionSelectionView.frame = view.bounds
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraLiveTextViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            try imageRequestHandler.perform([textRecognitionRequest])
        } catch {
            print("텍스트 인식 오류: \(error)")
        }
    }
}

// MARK: - RegionSelectionViewDelegate
extension CameraLiveTextViewController: RegionSelectionViewDelegate {
    func didSelectRegion(_ region: CGRect) {
        selectedRegion = region
        isRegionSelected = true
        showTextInSelectedRegion()
    }
    
    func didCancelSelection() {
        isRegionSelected = false
        selectedRegion = .zero
    }
}

// MARK: - TextElement
struct TextElement {
    let text: String
    let boundingBox: CGRect
    let confidence: Float
}

// MARK: - RegionSelectionView
protocol RegionSelectionViewDelegate: AnyObject {
    func didSelectRegion(_ region: CGRect)
    func didCancelSelection()
}

class RegionSelectionView: UIView {
    weak var delegate: RegionSelectionViewDelegate?
    
    private var startPoint: CGPoint = .zero
    private var currentPoint: CGPoint = .zero
    private var isDragging = false
    private var selectionLayer: CAShapeLayer?
    private var overlayLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = true
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        // 오버레이 레이어 (선택되지 않은 영역을 어둡게)
        overlayLayer = CALayer()
        overlayLayer?.backgroundColor = UIColor.black.withAlphaComponent(0.4).cgColor
        overlayLayer?.frame = bounds
        layer.addSublayer(overlayLayer!)
        
        // 선택 영역 레이어
        selectionLayer = CAShapeLayer()
        selectionLayer?.strokeColor = UIColor.systemBlue.cgColor
        selectionLayer?.lineWidth = 2
        selectionLayer?.fillColor = UIColor.clear.cgColor
        selectionLayer?.lineDashPattern = [5, 5]
        layer.addSublayer(selectionLayer!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        startPoint = touch.location(in: self)
        currentPoint = startPoint
        isDragging = true
        updateSelection()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDragging else { return }
        currentPoint = touch.location(in: self)
        updateSelection()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        isDragging = false
        
        let selectedRect = CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(currentPoint.x - startPoint.x),
            height: abs(currentPoint.y - startPoint.y)
        )
        
        // 최소 크기 체크
        if selectedRect.width > 50 && selectedRect.height > 50 {
            delegate?.didSelectRegion(selectedRect)
        } else {
            delegate?.didCancelSelection()
            resetSelection()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        delegate?.didCancelSelection()
        resetSelection()
    }
    
    private func updateSelection() {
        let selectedRect = CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(currentPoint.x - startPoint.x),
            height: abs(currentPoint.y - startPoint.y)
        )
        
        // 선택 영역 그리기
        let selectionPath = UIBezierPath(rect: selectedRect)
        selectionLayer?.path = selectionPath.cgPath
        
        // 오버레이 마스크 업데이트 (선택된 영역만 투명하게)
        let maskPath = UIBezierPath(rect: bounds)
        maskPath.append(UIBezierPath(rect: selectedRect).reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = .evenOdd
        overlayLayer?.mask = maskLayer
    }
    
    private func resetSelection() {
        selectionLayer?.path = nil
        overlayLayer?.mask = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlayLayer?.frame = bounds
    }
}
