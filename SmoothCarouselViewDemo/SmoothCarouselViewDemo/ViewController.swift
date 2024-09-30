//
//  ViewController.swift
//  SmoothCarouselViewDemo
//
//  Created by Shubham Sharma on 30/09/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var carouselContainerView: UIView!
    @IBOutlet private weak var addMoreButton: UIButton!
    @IBOutlet private weak var pageControl: UIPageControl!
    
    private var carouselView: SmoothCarouselView?
    private var cats: [String] = ["cat-1", "cat-2", "cat-3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let catsImages = cats.map { createCardView(with: $0) }
        let carouselView = SmoothCarouselView(cards: catsImages)
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        carouselContainerView.addSubview(carouselView)
        
        NSLayoutConstraint.activate([
            carouselView.leadingAnchor.constraint(equalTo: carouselContainerView.leadingAnchor),
            carouselView.trailingAnchor.constraint(equalTo: carouselContainerView.trailingAnchor),
            carouselView.topAnchor.constraint(equalTo: carouselContainerView.topAnchor),
            carouselView.bottomAnchor.constraint(equalTo: carouselContainerView.bottomAnchor)
        ])
        self.carouselView = carouselView
        self.carouselView?.focuedCardDidChange = updatePageControl
    }
    
    @IBAction func addMoreCats(_ sender: UIButton) {
        let newCats = ["cat-4", "cat-5", "cat-6"]
        cats.append(contentsOf: newCats)
        let moreCatsImages = newCats.map { createCardView(with: $0)}
        carouselView?.appendCards(moreCatsImages)
        pageControl.numberOfPages = cats.count
        
        sender.isEnabled = false
    }
    
    private func createCardView(with imageName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }
    
    func updatePageControl(_ index: Int) {
        pageControl.currentPage = index
    }
}

