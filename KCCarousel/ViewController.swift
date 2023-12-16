//
//  ViewController.swift
//  KCCarousel
//
//  Created by Thomas on 2023/12/16.
//

import UIKit

class ViewController: UIViewController {
    
    let carouselView = CarouselView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(carouselView)
        carouselView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor,paddingTop: 100, height: 200)
        let imageNames = ["01", "02", "03", "04", "05"]
        let links = ["", "https://google.com", "https://baidu.com","",""]
        
        var carouselImages = [CarouselImage]()
        for (imageName, linkString) in zip(imageNames, links) {
            if let image = UIImage(named: imageName) {
                let link = URL(string: linkString)
                let carouselImage = CarouselImage(image: image, link: link)
                carouselImages.append(carouselImage)
            }
        }
        carouselView.datas = carouselImages
        carouselView.isPageControlHidden = false
        carouselView.isAutoScrollEnabled = true
        carouselView.autoScrollInterval = 5
    }
    
}

