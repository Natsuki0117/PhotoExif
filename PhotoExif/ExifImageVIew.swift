//
//  ExifImageVIew.swift
//  PhotoExif
//
//  Created by 金井菜津希 on 2025/03/27.
//

import SwiftUI

enum ImageType: CaseIterable {
    case frame1
    case frame2
}
 
struct ExifImage: View {
    
    var exif: ExifData?
    var type: ImageType
 
    private let margin = CGFloat(16)
 
    var body: some View {
        switch type {
        case .frame1:
            Group {
                VStack(spacing: 4) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, margin)
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
        
        case .frame2:
            Group {
                VStack(spacing: 4) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, margin)
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
                    .padding(.bottom)
                }
                .bold()
            }
            .background(Color.white)
        }
    }
    
    var image: UIImage {
        exif?.imageData.flatMap(UIImage.init(data:)) ?? .filled()
    }
 
    var cameraMaker: String {
        exif?.cameraMaker ?? "Unknown Maker"
    }
 
    var cameraModel: String {
        exif?.cameraModel ?? "Unknown Camera"
    }
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
