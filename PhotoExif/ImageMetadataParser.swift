//
//  ImageMetadataParser.swift
//  PhotoExif
//
//  Created by 金井菜津希 on 2025/03/27.
//

import CoreImage
 
struct ImageMetadataParser {
    private let imageMetadataKeys = ImageMetadataKeys.shared
    private let properties: [String: Any]
 
    init?(data: Data) {
        guard let properties = CIImage(data: data)?.properties else {
            return nil
        }
        self.properties = properties
    }
 
    func parse<T>(for keyPath: KeyPath<ImageMetadataKeys, ImageMetadataKey<T>>) -> T? {
        let key = imageMetadataKeys[keyPath: keyPath]
        let targetDictionary: [String: Any] = {
            guard let parentDictionaryKey = key.parentDictionaryKey else {
                return properties
            }
            return parse(from: properties, for: parentDictionaryKey.keyName) ?? .init()
        }()
        return parse(from: targetDictionary, for: key.keyName)
    }
 
    private func parse<T>(
        from dictionary: [String: Any],
        for keyName: CFString
    ) -> T? {
        dictionary[keyName as String] as? T
    }
}
 
extension ImageMetadataParser {
    struct ImageMetadataDictionaryKey {
        let keyName: CFString
    }
 
    struct ImageMetadataKey<T> {
        let keyName: CFString
        let parentDictionaryKey: ImageMetadataDictionaryKey?
    }
 
    struct ImageMetadataKeys {
        static let shared = Self()
 
        private init() {
        }
 
        private enum MetadataDictionary {
            static let exif = ImageMetadataDictionaryKey(keyName: kCGImagePropertyExifDictionary)
            static let auxiliaryExif = ImageMetadataDictionaryKey(keyName: kCGImagePropertyExifAuxDictionary)
            static let tiff = ImageMetadataDictionaryKey(keyName: kCGImagePropertyTIFFDictionary)
        }
 
 
        // MARK: Lens Information
        let lensMaker = ImageMetadataKey<String>(
            keyName: kCGImagePropertyExifLensMake,
            parentDictionaryKey: MetadataDictionary.exif
        )
        let lensModel = ImageMetadataKey<String>(
            keyName: kCGImagePropertyExifLensModel,
            parentDictionaryKey: MetadataDictionary.exif
        )
 
        // MARK: Camera Information
        let cameraMaker = ImageMetadataKey<String>(
            keyName: kCGImagePropertyTIFFMake,
            parentDictionaryKey: MetadataDictionary.tiff
        )
        let cameraModel = ImageMetadataKey<String>(
            keyName: kCGImagePropertyTIFFModel,
            parentDictionaryKey: MetadataDictionary.tiff
        )
 
        // MARK: Camera Settings
        /// F値
        let fNumber = ImageMetadataKey<Double>(
            keyName: kCGImagePropertyExifFNumber,
            parentDictionaryKey: MetadataDictionary.exif
        )
        /// シャッタースピード
        let shutterSpeed = ImageMetadataKey<Double>(
            keyName: kCGImagePropertyExifShutterSpeedValue,
            parentDictionaryKey: MetadataDictionary.exif
        )
        /// 露光時間
        let exposureTime = ImageMetadataKey<Double>(
            keyName: kCGImagePropertyExifExposureTime,
            parentDictionaryKey: MetadataDictionary.exif
        )
        /// ISO感度
        let isoSpeedRatings = ImageMetadataKey<[Int]>(
            keyName: kCGImagePropertyExifISOSpeedRatings,
            parentDictionaryKey: MetadataDictionary.exif
        )
    }
}
