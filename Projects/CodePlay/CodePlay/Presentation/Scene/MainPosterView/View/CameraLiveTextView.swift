//
//  CameraLiveTextView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/24/25.
//

import AVFoundation
import SwiftUI
import UIKit
import Vision

struct CameraLiveTextView: View {
    @Binding var recognizedText: String
    @Binding var isPresented: Bool
    @EnvironmentObject var wrapper: PosterViewModelWrapper
    @State private var showCoachMark = !UserDefaults.standard.bool(forKey: "hasSeenCameraCoachMark")
    
    var body: some View {
        ZStack {
            CameraLiveTextViewRepresentable(
                recognizedText: $recognizedText,
                isPresented: $isPresented
            )
            .environmentObject(wrapper)
            // 코치마크 오버레이
            if showCoachMark {
                CoachMarkView(
                    isPresented: $showCoachMark,
                    onCompleted: {
                        UserDefaults.standard.set(true, forKey: "hasSeenCameraCoachMark")
                        showCoachMark = false
                    }
                )
            }
        }
    }
}

struct CameraLiveTextViewRepresentable: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    @Binding var isPresented: Bool
    @EnvironmentObject var wrapper: PosterViewModelWrapper

    func makeUIViewController(context: Context) -> CameraLiveTextViewController
    {
        let controller = CameraLiveTextViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: CameraLiveTextViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraLiveTextDelegate {
        let parent: CameraLiveTextViewRepresentable

        init(_ parent: CameraLiveTextViewRepresentable) {
            self.parent = parent
        }

        func didSelectRegion(with text: String) {
            DispatchQueue.main.async {
                self.parent.recognizedText = text
                self.parent.wrapper.viewModel.scannedText.value = RawText(
                    text: text
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.parent.wrapper.viewModel.shouldNavigateToFestivalCheck
                        .value = true
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
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(
                self,
                queue: DispatchQueue(label: "videoQueue")
            )

            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

        } catch {
        }
    }

    private func setupTextRecognition() {
        textRecognitionRequest = VNRecognizeTextRequest {
            [weak self] request, error in
            guard let self = self,
                let observations = request.results
                    as? [VNRecognizedTextObservation],
                error == nil
            else { return }

            var textElements: [TextElement] = []

            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first
                else { continue }

                let boundingBox = observation.boundingBox
                let convertedRect = self.previewLayer.layerRectConverted(
                    fromMetadataOutputRect: boundingBox
                )

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
        textRecognitionRequest.minimumTextHeight = 0.03  // 작은 텍스트도 인식하도록 설정
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
        closeButton.addTarget(
            self,
            action: #selector(closeButtonTapped),
            for: .touchUpInside
        )

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            closeButton.trailingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 60
            ),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
        ])

        // 컨테이너 뷰 생성
        let instructionContainer = UIView()
        instructionContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        instructionContainer.layer.cornerRadius = 8
        instructionContainer.clipsToBounds = true

        let instructionLabel = UILabel()
        instructionLabel.text = "텍스트를 드래그하는 동안 움직이지 마세요."
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 14) // 폰트 사이즈 작게

        instructionContainer.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(instructionContainer)
        instructionContainer.addSubview(instructionLabel)

        NSLayoutConstraint.activate([
            // 컨테이너 뷰 제약조건
            instructionContainer.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 70
            ),
            instructionContainer.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            instructionContainer.heightAnchor.constraint(equalToConstant: 32),
            
            instructionLabel.leadingAnchor.constraint(
                equalTo: instructionContainer.leadingAnchor,
                constant: 8
            ),
            instructionLabel.trailingAnchor.constraint(
                equalTo: instructionContainer.trailingAnchor,
                constant: -8
            ),
            instructionLabel.centerYAnchor.constraint(
                equalTo: instructionContainer.centerYAnchor
            ),
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
extension CameraLiveTextViewController:
    AVCaptureVideoDataOutputSampleBufferDelegate
{
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }

        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .up,
            options: [:]
        )

        do {
            try imageRequestHandler.perform([textRecognitionRequest])
        } catch {
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

// MARK: - RegionSelectionView (Fixed QR Code Style Area)
class RegionSelectionView: UIView {
    weak var delegate: RegionSelectionViewDelegate?

    private var startPoint: CGPoint = .zero
    private var currentPoint: CGPoint = .zero
    private var isDragging = false
    private var overlayLayer: CALayer?
    private var cornerLayers: [CAShapeLayer] = []
    private var guideLayers: [CAShapeLayer] = []
    private var selectionLayer: CAShapeLayer?

    // 고정된 드래그 영역 설정
    private var fixedDragArea: CGRect = .zero

    // QR 코드 스타일 설정
    private let cornerLength: CGFloat = 40
    private let cornerWidth: CGFloat = 6
    private let guideLineWidth: CGFloat = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = true
        setupFixedDragArea()
        setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupFixedDragArea() {
        // 화면 중앙에 고정된 정사각형 영역 설정
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let areaWidth = screenWidth * 0.98
        let areaHeight = screenHeight * 0.6
        fixedDragArea = CGRect(
            x: (screenWidth - areaWidth) / 2,
            y: (screenHeight - areaHeight) / 2,
            width: areaWidth,
            height: areaHeight + 130
        )

    }

    private func setupLayers() {
        // 오버레이 레이어 (드래그 영역 외부를 어둡게)
        overlayLayer = CALayer()
        overlayLayer?.backgroundColor =
            UIColor.black.withAlphaComponent(0.6).cgColor
        overlayLayer?.frame = bounds
        layer.addSublayer(overlayLayer!)

        // 고정 영역 마스크 적용
        updateFixedAreaMask()

        // 코너, 가이드라인, 선택 레이어 설정
        setupCornerLayers()
        setupGuideLayers()
        setupSelectionLayer()

        // 초기에 고정 영역과 가이드라인 표시
        showFixedArea()
        showGuideLines(true)
    }

    private func updateFixedAreaMask() {
        // 고정 영역만 투명하게, 나머지는 어둡게
        let maskPath = UIBezierPath(rect: bounds)
        let fixedAreaPath = UIBezierPath(
            roundedRect: fixedDragArea,
            cornerRadius: 12
        )
        maskPath.append(fixedAreaPath.reversing())

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = .evenOdd
        overlayLayer?.mask = maskLayer
    }

    private func setupCornerLayers() {
        // 4개 코너 레이어 생성
        for _ in 0..<4 {
            let cornerLayer = CAShapeLayer()
            cornerLayer.strokeColor = UIColor.systemBlue.cgColor
            cornerLayer.lineWidth = cornerWidth
            cornerLayer.fillColor = UIColor.clear.cgColor
            cornerLayer.lineCap = .round
            layer.addSublayer(cornerLayer)
            cornerLayers.append(cornerLayer)
        }
    }

    private func setupGuideLayers() {
        // 가이드 라인 레이어들 (3x3 격자)
        for _ in 0..<4 {  // 2개의 세로선, 2개의 가로선
            let guideLayer = CAShapeLayer()
            guideLayer.strokeColor =
                UIColor.white.withAlphaComponent(0.1).cgColor
            guideLayer.lineWidth = guideLineWidth
            guideLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(guideLayer)
            guideLayers.append(guideLayer)
        }
    }

    private func setupSelectionLayer() {
        // 실제 드래그 선택 영역 레이어
        selectionLayer = CAShapeLayer()
        selectionLayer?.strokeColor = UIColor.systemYellow.cgColor
        selectionLayer?.lineWidth = 2
        selectionLayer?.fillColor =
            UIColor.systemYellow.withAlphaComponent(0.1).cgColor
        selectionLayer?.isHidden = true
        layer.addSublayer(selectionLayer!)
    }

    private func showFixedArea() {
        // 고정 영역의 QR 코드 스타일 코너 표시
        updateCorners(for: fixedDragArea)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: self)

        // 고정 영역 내부에서만 드래그 시작 허용
        guard fixedDragArea.contains(touchPoint) else { return }

        startPoint = touchPoint
        currentPoint = touchPoint
        isDragging = true

        // 드래그 시작 시 선택 레이어 표시
        selectionLayer?.isHidden = false
        updateSelection()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDragging else { return }
        let touchPoint = touch.location(in: self)

        // 고정 영역 내부로 제한
        currentPoint = CGPoint(
            x: max(fixedDragArea.minX, min(fixedDragArea.maxX, touchPoint.x)),
            y: max(fixedDragArea.minY, min(fixedDragArea.maxY, touchPoint.y))
        )

        updateSelection()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        isDragging = false

        var selectedRect = CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(currentPoint.x - startPoint.x),
            height: abs(currentPoint.y - startPoint.y)
        )

        // 고정 영역 내부로 제한
        selectedRect = selectedRect.intersection(fixedDragArea)

        // 최소 크기 체크
        if selectedRect.width > 60 && selectedRect.height > 60 {
            // 선택 완료 효과
            animateSelectionComplete(selectedRect)

            // 0.5초 후 텍스트 인식 실행
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.didSelectRegion(selectedRect)
                self.resetSelection()
            }
        } else {
            delegate?.didCancelSelection()
            resetSelection()
        }
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        isDragging = false
        delegate?.didCancelSelection()
        resetSelection()
    }

    private func updateSelection() {
        guard isDragging else { return }

        let selectedRect = CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(currentPoint.x - startPoint.x),
            height: abs(currentPoint.y - startPoint.y)
        )

        // 선택 영역 표시
        let selectionPath = UIBezierPath(
            roundedRect: selectedRect,
            cornerRadius: 6
        )
        selectionLayer?.path = selectionPath.cgPath
    }

    private func animateSelectionComplete(_ rect: CGRect) {
        // 선택 완료 시 깜빡이는 효과
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.3
        animation.duration = 0.2
        animation.autoreverses = true
        animation.repeatCount = 2

        selectionLayer?.add(animation, forKey: "completeBlink")
    }

    private func updateCorners(for rect: CGRect) {
        let corners = [
            CGPoint(x: rect.minX, y: rect.minY),  // 좌상단
            CGPoint(x: rect.maxX, y: rect.minY),  // 우상단
            CGPoint(x: rect.minX, y: rect.maxY),  // 좌하단
            CGPoint(x: rect.maxX, y: rect.maxY),  // 우하단
        ]

        for (index, corner) in corners.enumerated() {
            let cornerPath = UIBezierPath()

            switch index {
            case 0:  // 좌상단
                cornerPath.move(
                    to: CGPoint(x: corner.x, y: corner.y + cornerLength)
                )
                cornerPath.addLine(to: corner)
                cornerPath.addLine(
                    to: CGPoint(x: corner.x + cornerLength, y: corner.y)
                )
            case 1:  // 우상단
                cornerPath.move(
                    to: CGPoint(x: corner.x - cornerLength, y: corner.y)
                )
                cornerPath.addLine(to: corner)
                cornerPath.addLine(
                    to: CGPoint(x: corner.x, y: corner.y + cornerLength)
                )
            case 2:  // 좌하단
                cornerPath.move(
                    to: CGPoint(x: corner.x, y: corner.y - cornerLength)
                )
                cornerPath.addLine(to: corner)
                cornerPath.addLine(
                    to: CGPoint(x: corner.x + cornerLength, y: corner.y)
                )
            case 3:  // 우하단
                cornerPath.move(
                    to: CGPoint(x: corner.x - cornerLength, y: corner.y)
                )
                cornerPath.addLine(to: corner)
                cornerPath.addLine(
                    to: CGPoint(x: corner.x, y: corner.y - cornerLength)
                )
            default:
                break
            }

            cornerLayers[index].path = cornerPath.cgPath
        }
    }

    private func showGuideLines(_ show: Bool) {
        if show {
            // 세로 가이드 라인 2개 (1/3, 2/3 지점)
            for i in 0..<2 {
                let x =
                    fixedDragArea.minX + fixedDragArea.width * CGFloat(i + 1)
                    / 3
                let verticalPath = UIBezierPath()
                verticalPath.move(to: CGPoint(x: x, y: fixedDragArea.minY))
                verticalPath.addLine(to: CGPoint(x: x, y: fixedDragArea.maxY))
                guideLayers[i].path = verticalPath.cgPath
            }

            // 가로 가이드 라인 2개 (1/3, 2/3 지점)
            for i in 0..<2 {
                let y =
                    fixedDragArea.minY + fixedDragArea.height * CGFloat(i + 1)
                    / 3
                let horizontalPath = UIBezierPath()
                horizontalPath.move(to: CGPoint(x: fixedDragArea.minX, y: y))
                horizontalPath.addLine(to: CGPoint(x: fixedDragArea.maxX, y: y))
                guideLayers[i + 2].path = horizontalPath.cgPath
            }
        }

        for guideLayer in guideLayers {
            guideLayer.isHidden = !show
        }
    }

    private func resetSelection() {
        selectionLayer?.isHidden = true
        selectionLayer?.path = nil
        selectionLayer?.removeAllAnimations()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayLayer?.frame = bounds

        // 화면 크기 변경 시 고정 영역 재계산
        setupFixedDragArea()
        updateFixedAreaMask()
        showFixedArea()
        showGuideLines(true)
    }
}

// MARK: - Usage in CameraLiveTextViewController
extension CameraLiveTextViewController {

    // setupUI 메서드에 추가할 코드
    private func addFixedAreaInstructions() {
        // 상단 안내 텍스트
        let titleLabel = UILabel()
        titleLabel.text = "포스터를 드래그하는 동안 화면을 움직이지 마세요."
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        titleLabel.layer.cornerRadius = 8
        titleLabel.clipsToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // 하단 안내 텍스트
        let instructionLabel = UILabel()
        instructionLabel.text = "카메라를 안정적으로 유지하세요"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textAlignment = .center
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        instructionLabel.layer.cornerRadius = 6
        instructionLabel.clipsToBounds = true

        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        NSLayoutConstraint.activate([
            // 상단 제목
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 120
            ),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 36),
            titleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 20
            ),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -20
            ),

            // 하단 안내
            instructionLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -120
            ),
            instructionLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            instructionLabel.heightAnchor.constraint(equalToConstant: 32),
            instructionLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 20
            ),
            instructionLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -20
            ),
        ])
    }
}
