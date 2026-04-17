//
//  ImageListPresenterSpy.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

@testable import ImageFeed
import Foundation

final class ImageListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    let numberOfRows: Int = 0
    
    func didSelectRow(at indexPath: IndexPath) {
        
    }
    
    func willDisplayRow(at indexPath: IndexPath) {
        
    }
    
    func didTapLike(at indexPath: IndexPath) {
        
    }
    
    func cellViewModel(for indexPath: IndexPath) -> ImagesListCellViewModel {
        // Return a simple stubbed view model to satisfy protocol and allow tests to proceed
        return ImagesListCellViewModel(
            imageURL: URL(string: "https://example.com/image.jpg")!,
            dateText: "10/10/2020",
            isLiked: false
        )
    }
    
    func heightForRow(at indexPath: IndexPath, tableWidth: CGFloat) -> CGFloat {
        0
    }
    
    func viewDidLoad(){
        viewDidLoadCalled = true
    }
    

}
