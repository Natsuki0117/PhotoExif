//
//  ContentView.swift
//  PhotoExif
//
//  Created by 金井菜津希 on 2025/03/27.
//

import Combine
import PhotosUI
import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @Environment(\.displayScale) private var displayScale
    @State private var savedImage: UIImage?
    @State private var isImageSaved = false
    @State private var images: [UIImage] = []
    @State private var selectedType: ImageType = .frame1
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                TabView(selection: $selectedType) {
                    ForEach(ImageType.allCases, id: \.self) { imageType in
                        ExifImage(exif: viewModel.exif, type: imageType)
                            .shadow(radius: 10)
                            .padding(16)
                            .tag(imageType)
                    }
                }
                .tabViewStyle(.page)
            


                Spacer()
                HStack {
                    PhotosPicker(
                        selection: $viewModel.pickedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("SELECT ")
                            .frame(width: 150, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(.infinity)
                    .frame(maxWidth: .infinity)
                    .shadow(radius: CGFloat(15))

                    Button("SAVE"){
                        if viewModel.pickedPhoto == nil {
                            alertMessage = "写真を選択してください"
                            showAlert = true
                        }else  if let image = ExifImage(exif: viewModel.exif, type: selectedType)
                            .frame(width: geometry.size.width)
                            .snapshot(scale: displayScale) {
                            PhotoLibraryManager.shared.saveImageToAlbum(image, albumName: "exif") {
                                isImageSaved = true
                                alertMessage = "保存ができました"
                                showAlert = true
                            }
                        }
                    }
                    .frame(width: 150, height: 40)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(40)
                    .frame(maxWidth: .infinity)
                    .shadow(radius: CGFloat(15))
    
                    .alert(alertMessage, isPresented: $showAlert) {
                        Button("OK", role: .cancel) {}
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.white)
        }
    }

}

class PhotoLibraryManager {
    static let shared = PhotoLibraryManager()

    func saveImageToAlbum(_ image: UIImage, albumName: String, completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
                let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

                var albumChangeRequest: PHAssetCollectionChangeRequest?
                if let existingAlbum = collection.firstObject {
                    albumChangeRequest = PHAssetCollectionChangeRequest(for: existingAlbum)
                } else {
                    let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                    albumChangeRequest = createAlbumRequest
                }

                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder = assetChangeRequest.placeholderForCreatedAsset
                if let albumChangeRequest = albumChangeRequest, let placeholder = placeholder {
                    albumChangeRequest.addAssets([placeholder] as NSArray)
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
    
    func fetchAlbum(named albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collections.firstObject
    }
    
    func fetchPhotos(from album: PHAssetCollection) -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        
        var assetArray: [PHAsset] = []
        assets.enumerateObjects { (asset, _, _) in
            assetArray.append(asset)
        }
        return assetArray
    }
    
    func getUIImage(from asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .aspectFit,
                                  options: options) { image, _ in
            DispatchQueue.main.async {
                completion(image)
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
