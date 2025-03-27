//
//  ContentViewModel.swift
//  PhotoExif
//
//  Created by 金井菜津希 on 2025/03/27.
//

import Combine
import PhotosUI
import SwiftUI
 
@MainActor
final class ContentViewModel: ObservableObject {
    @Published var pickedPhoto: PhotosPickerItem?
 
    @Published private(set) var exif: ExifData?
 
    private var cancellables = Set<AnyCancellable>()
 
    init() {
        $pickedPhoto
            .receive(on: DispatchQueue.main)
            .sink { _ in
                Task { @MainActor in
                    await self.parse()
                }
            }
            .store(in: &cancellables)
    }
 
    private func parse() async {
        guard
            let imageData = try? await pickedPhoto?.loadTransferable(type: Data.self),
            let parser = ImageMetadataParser(data: imageData)
        else {
            return
        }
        exif = .init(
            imageData: imageData,
            cameraMaker: parser.parse(for: \.cameraMaker),
            cameraModel: parser.parse(for: \.cameraModel),
            lensModel: parser.parse(for: \.lensModel),
            fNumber: parser.parse(for: \.fNumber),
            exposureTime: parser.parse(for: \.exposureTime).map(Fraction.init(number:)),
            iso: parser.parse(for: \.isoSpeedRatings)?.first
        )
    }
}
