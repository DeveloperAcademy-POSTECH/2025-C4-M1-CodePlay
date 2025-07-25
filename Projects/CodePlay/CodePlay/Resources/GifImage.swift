//
//  GifImage.swift
//  CodePlay
//
//  Created by Three on 7/25/25.
//

import SwiftUI
import UIKit
import ImageIO

struct GIFImage: UIViewRepresentable {
    let gifName: String
    let width: CGFloat
    let height: CGFloat

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        container.addSubview(imageView)

        // ✅ 이미지뷰를 container에 정확히 고정
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: width),
            imageView.heightAnchor.constraint(equalToConstant: height),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: width),
            container.heightAnchor.constraint(equalToConstant: height)
        ])

        if let path = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let source = CGImageSourceCreateWithData(data as CFData, nil) {

            var images: [UIImage] = []
            let count = CGImageSourceGetCount(source)
            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                }
            }

            imageView.animationImages = images
            imageView.animationDuration = Double(count) * 0.05
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
