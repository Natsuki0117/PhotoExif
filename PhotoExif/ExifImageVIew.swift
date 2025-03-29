//
//  ExifImageVIew.swift
//  PhotoExif
//
//  Created by 金井菜津希 on 2025/03/27.
//

import SwiftUI
 
struct ExifImage: View {
    private var exif: ExifData?

 
    private let margin = CGFloat(16)
    //たぶんこの16が余白を設定してるとこ
 
    init(
        exif: ExifData?
    ) {
        self.exif = exif

    }
 
    var body: some View {
        Group {
            VStack(spacing: 4) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, margin)
                    //この.bottomが画像とexifの間の余白、marginはそれに加えて全方向16px開けてるんだと思う
                Group {
                    HStack {
                        Text(cameraMaker)
                        Text(cameraModel)
                    }
                    .foregroundColor(Color.black)
                }
                HStack {
                    Text(fNumber)
                    Text(shutterSpeed)
                    Text(iso)
                }
                .foregroundColor(Color.black)
            }
            .bold()
            .padding(margin)
        }
        .background(Color.white)
    }
}
 
private extension ExifImage {
    var image: UIImage {
        exif?.imageData.flatMap(UIImage.init(data:)) ?? .filled()
    }
 
    var cameraMaker: String {
        exif?.cameraMaker ?? "Unknown Maker"
    }
 
    var cameraModel: String {
        exif?.cameraModel ?? "Unknown Camera"
    }
// 
//    var lensModel: String {
//        exif?.lensModel ?? "Unknown Lens"
//    }

    var fNumber: String {
        "f/" + .init(format: "%.1f", exif?.fNumber ?? .zero)
    }
 
    var shutterSpeed: String {
        "\(exif?.exposureTime?.fractionalExpression ?? "0")s"
    }
 
    var iso: String {
        "ISO\(exif?.iso ?? .zero)"
    }
}
 
extension UIImage {
    static func filled(with color: UIColor = .black) -> UIImage {
        let rect = CGRect(
            origin: .zero,
            size: .init(width: 1, height: 1)
        )
        return UIGraphicsImageRenderer(size: rect.size)
            .image {
                $0.cgContext.setFillColor(color.cgColor)
                $0.fill(rect)
            }
    }
}
