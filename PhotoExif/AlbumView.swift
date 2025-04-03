//
//  AlbumVIew.swift
//  PhotoExif
//
//  Created by 金井菜津希 on 2025/03/27.
//

import SwiftUI
import Photos

struct AlbumView: View {
    @State private var images: [UIImage] = []
        
    var body: some View {
        ZStack{
           
            VStack {
       
                ScrollView(.horizontal){
                    LazyHStack {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.main.bounds.width - 40)
                                .shadow(radius: 10)
                        }
                    }
                }
                .padding()
                .scrollTargetBehavior(.paging)

            }
            
            .onAppear {
                loadImages()
            }
        }
        .background(Color.white)
    }
        
    
        
    // 画像をアルバムから取得するメソッド
    func loadImages() {
        guard let album = PhotoLibraryManager.shared.fetchAlbum(named: "exif") else { return }
        let assets = PhotoLibraryManager.shared.fetchPhotos(from: album)
        images.removeAll()

        for asset in assets {
            PhotoLibraryManager.shared.getUIImage(from: asset) { image in
                if let image = image {
                    images.append(image)
                }
            }
        }
    }

}
