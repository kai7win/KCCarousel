//
//  CarouselView.swift
//  KCCarousel
//
//  Created by Thomas on 2023/12/16.
//

import UIKit

struct CarouselImage{
    let image:UIImage
    var link:URL?
}

class CarouselView: UIView, UIScrollViewDelegate {
    
    var datas: [CarouselImage] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var scrollView: UIScrollView!
    private var pageControl: UIPageControl!
    private var timer: Timer?
    
    var isAutoScrollEnabled: Bool = false {
        didSet{
            startTimer()
        }
    }
    var autoScrollInterval: TimeInterval = 3.0
    
    
    var isPageControlHidden: Bool {
        get { return pageControl.isHidden }
        set { pageControl.isHidden = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupImages()
    }
    
    private func configure() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        
        pageControl = UIPageControl()
        self.addSubview(pageControl)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            pageControl.heightAnchor.constraint(equalToConstant: 30),
            pageControl.leftAnchor.constraint(equalTo: self.leftAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            pageControl.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
    }
    
    
    private func setupImages() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let totalImages = datas.count + 2  // Add front and back copies
        scrollView.contentSize = CGSize(width: self.frame.width * CGFloat(totalImages), height: self.frame.height)
        scrollView.contentOffset = CGPoint(x: self.frame.width, y: 0)

        for i in 0..<totalImages {
            let imageView = UIImageView(frame: CGRect(x: self.frame.width * CGFloat(i), y: 0, width: self.frame.width, height: self.frame.height))
            imageView.contentMode = .scaleAspectFill
            let index: Int
            if i == 0 {
                index = datas.count - 1  // Copy of the last image
            } else if i == totalImages - 1 {
                index = 0  // Copy of the first image
            } else {
                index = i - 1
            }
            
            imageView.image = datas[index].image
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            scrollView.addSubview(imageView)
        }

        pageControl.numberOfPages = datas.count
    }

    
    func startTimer() {
        timer?.invalidate()
        if isAutoScrollEnabled {
            timer = Timer.scheduledTimer(timeInterval: autoScrollInterval, target: self, selector: #selector(moveToNextImage), userInfo: nil, repeats: true)
        }
    }
    
    
    @objc private func moveToNextImage() {
        let pageWidth = scrollView.frame.width
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)
        let nextPage = currentPage + 1

        if nextPage < datas.count + 2 {  // Determine if it's out of bounds
            scrollView.scrollRectToVisible(CGRect(x: pageWidth * CGFloat(nextPage), y: 0, width: pageWidth, height: scrollView.frame.height), animated: true)
        } else {
            // If out of bounds, jump to the copy of the first image without animation
            scrollView.contentOffset = CGPoint(x: pageWidth, y: 0)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let totalImages = datas.count + 2 // Add front and back copies
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)

        // Update pageControl
        if currentPage == 0 {
            pageControl.currentPage = datas.count - 1
        } else if currentPage == totalImages - 1 {
            pageControl.currentPage = 0
        } else {
            pageControl.currentPage = currentPage - 1
        }

        // Seamless loop handling
        if currentPage == 0 {
            // Scroll to the copy of the last image
            scrollView.contentOffset = CGPoint(x: pageWidth * CGFloat(datas.count), y: 0)
        } else if currentPage == totalImages - 1 {
            // Scroll to the copy of the first image
            scrollView.contentOffset = CGPoint(x: pageWidth, y: 0)
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startTimer()
    }
    
    
    @objc private func imageTapped(_ gesture: UITapGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView {
            let index = imageView.tag
            if index < datas.count, let url = datas[index].link {
                UIApplication.shared.open(url)
            }
        }
    }
}

