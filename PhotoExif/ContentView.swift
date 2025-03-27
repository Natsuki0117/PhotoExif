//
//  ContentView.swift
//  PhotoExif
//
//  Created by 金井菜津希 on 2025/03/27.
//


import Combine
import PhotosUI
import SwiftUI
 
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @Environment(\.displayScale) private var displayScale
 
    private var exifImage: ExifImage {
        .init(
            exif: viewModel.exif
        )
    }
 
    var body: some View {
            
            GeometryReader { geometry in
                VStack {
                    exifImage
     
                    HStack{
                        
                        PhotosPicker(
                            selection: $viewModel.pickedPhoto,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Text("Select a photo")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            if let image = exifImage
                                .frame(width: geometry.size.width)
                                .snapshot(scale: displayScale) {
                                PhotoLibraryManager.shared.saveImageToAlbum(image, albumName: "exif") {
//                                                                isImageSaved = true
                                                            }
                                       }
                                   } label: {
                                       Text("保存")
                                   }
                                   .buttonStyle(.bordered)
                                   

                        if let image = exifImage
                            .frame(width: geometry.size.width)
                            .snapshot(scale: displayScale)
                            .map(Image.init(uiImage:)) {
                            ShareLink(
                                "画像をシェアする",
                                item: image,
                                preview: .init(
                                    "Share ExiFrame Image",
                                    image: image
                                )
                            )
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
    //            .background(Color(red: 0.99568, green: 0.8232, blue: 0.88592))
                .background(Color("Background"))
                
            }
    }
}

class PhotoLibraryManager {
    static let shared = PhotoLibraryManager()

    func saveImageToAlbum(_ image: UIImage, albumName: String, completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }

            var albumPlaceholder: PHObjectPlaceholder?

            PHPhotoLibrary.shared().performChanges {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
                let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

                let albumChangeRequest: PHAssetCollectionChangeRequest
                if let existingAlbum = collection.firstObject {
                    albumChangeRequest = PHAssetCollectionChangeRequest(for: existingAlbum)!
                } else {
                    let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                    albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }

                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                if let placeholder = assetChangeRequest.placeholderForCreatedAsset,
                   let albumPlaceholder = albumPlaceholder,
                   let albumFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil).firstObject {
                    let addAssetRequest = PHAssetCollectionChangeRequest(for: albumFetchResult)
                    addAssetRequest?.addAssets([placeholder] as NSArray)
                }
            } completionHandler: { success, error in
                if success {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
}
 
extension View {
    @MainActor
    func snapshot(scale: CGFloat) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        return renderer.uiImage
    }
}
