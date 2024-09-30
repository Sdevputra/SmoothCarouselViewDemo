//
//  SmoothCarouselView.swift
//  SmoothCarouselViewDemo
//
//  Created by Shubham Sharma on 30/09/24.
//

import Foundation
import UIKit

class SmoothCarouselView: UIView {
    // MARK: Properties
    private var scrollView = UIScrollView()
    private var cards: [UIView] = []
    
    private(set) var focusedCardIndex: Int = 0 {
        didSet {
            focuedCardDidChange?(focusedCardIndex)
        }
    }
    
    private var lastBound: CGRect = .zero
    private var lastAddedCard: UIView?
    
    private var cardSize: CGSize {
        .init(width: bounds.height, height: bounds.height)
    }
    
    private var cardsWidthConstraints = Set<NSLayoutConstraint>()
    private var cardsHeightConstraints = Set<NSLayoutConstraint>()
    private var lastCardTrailingConstraint: NSLayoutConstraint?
    /// Define how much scaling should be applied, when transforming(scale up) focused card.
    private let scaleAmount: CGFloat = 0.2
    
    var focuedCardDidChange: ((Int) -> Void)?
        
    // MARK: Lifecycle
    init(frame: CGRect, cards: [UIView]) {
        super.init(frame: frame)
        
        self.cards = cards
        self.clipsToBounds = false
        setupScrollView()
        addCards(cards)
        updateScrollViewContentSize()
        updateScrollViewContentInset()
    }
    
    convenience init(cards: [UIView]) {
        self.init(frame: .zero, cards: cards)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // If bound change, then doing adjustments.
        if lastBound != bounds {
            lastBound = bounds
            updateCardsSize()
            updateScrollViewContentSize()
            updateScrollViewContentInset()
            updateScrollViewContentOffset()
        }
    }
    
    func appendCards(_ cards: [UIView]) {
        lastCardTrailingConstraint?.isActive = false
        lastCardTrailingConstraint = nil
        self.cards.append(contentsOf: cards)
        addCards(cards)
        self.layoutIfNeeded()
        self.updateScrollViewContentSize()
    }
}

// MARK: - UIScrollViewDelegate
extension SmoothCarouselView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.width <= frame.width {
            scrollView.subviews.forEach { cardView in
                cardView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        } else {
            updateCardScaling()
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetX = targetContentOffset.pointee.x
        
        if velocity.x > 0 {
            focusedCardIndex = min(focusedCardIndex + 1, cards.count - 1)
        } else if velocity.x < 0 {
            focusedCardIndex = max(focusedCardIndex - 1, 0)
        } else {
            focusedCardIndex = Int(round(targetX / cardSize.width))
        }

        let newOffsetX = CGFloat(focusedCardIndex) * cardSize.width - (frame.width - cardSize.width) / 2
        targetContentOffset.pointee = CGPoint(x: newOffsetX, y: targetContentOffset.pointee.y)
    }
}

// MARK: - Helpers
private extension SmoothCarouselView {
     func setupScrollView() {
        scrollView.clipsToBounds = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = false
        scrollView.decelerationRate = .fast
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: cardSize.width / 2, bottom: 0, right: cardSize.width / 2)
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
     func addCards(_ cards: [UIView]) {
        for aCard in cards {
            scrollView.addSubview(aCard)
            aCard.translatesAutoresizingMaskIntoConstraints = false
            
            let width = aCard.widthAnchor.constraint(equalToConstant: cardSize.width)
            cardsWidthConstraints.insert(width)
            let height = aCard.heightAnchor.constraint(equalToConstant: cardSize.height)
            cardsHeightConstraints.insert(height)
            
            NSLayoutConstraint.activate([width,
                                         height,
                                         aCard.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            ])

            if let last = lastAddedCard {
                aCard.leadingAnchor.constraint(equalTo: last.trailingAnchor).isActive = true
            } else {
                aCard.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            }
            lastAddedCard = aCard
        }

        if let last = lastAddedCard {
            lastCardTrailingConstraint = last.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
            lastCardTrailingConstraint?.isActive = true
        }
    }
    
     func updateScrollViewContentSize() {
        scrollView.contentSize = CGSize(width: CGFloat(cards.count) * cardSize.width, height: cardSize.height)
    }
    
     func updateScrollViewContentInset() {
        if scrollView.contentSize.width <= bounds.width {
            let diff = bounds.width - scrollView.contentSize.width
            scrollView.contentInset = UIEdgeInsets(top: 0, left: diff / 2, bottom: 0, right: diff/2)
            scrollView.decelerationRate = .normal
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: cardSize.width / 2, bottom: 0, right: cardSize.width / 2)
            scrollView.decelerationRate = .fast
        }
    }
    
     func updateScrollViewContentOffset() {
        if scrollView.contentSize.width <= scrollView.bounds.width {
            let diff = scrollView.bounds.width - scrollView.contentSize.width
            scrollView.setContentOffset(CGPoint(x: -diff/2, y: 0), animated: true)
        } else {
            let initialCardIndex = cards.count / 2
            let initialOffset = CGFloat(initialCardIndex) * cardSize.width - (frame.width - cardSize.width) / 2
            scrollView.contentOffset = CGPoint(x: initialOffset, y: 0)
            focusedCardIndex = initialCardIndex
        }
    }
    
     func updateCardsSize() {
        for aConstraint in cardsHeightConstraints {
            aConstraint.constant = cardSize.width
        }
        for aConstraint in cardsWidthConstraints {
            aConstraint.constant = cardSize.height
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
        
    private func updateCardScaling(animated: Bool = false) {
        let centerX = scrollView.center.x + scrollView.contentOffset.x
        
        scrollView.subviews.forEach { cardView in
            let distanceFromCenter = centerX - cardView.center.x
            let thresholdDistance = cardSize.width / 2
            
            if abs(distanceFromCenter) <= thresholdDistance {
                // The card is within the center threshold, so we should scale it up.
                let normalizedDistance = abs(distanceFromCenter) / thresholdDistance
                let scale = 1 + (scaleAmount * (1 - normalizedDistance))
                if animated {
                    UIView.animate(withDuration: 0.2) {
                        cardView.transform = CGAffineTransform(scaleX: scale, y: scale)
                    }
                } else {
                    cardView.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            } else {
                // The card is outside the center threshold, so we should remove the scaling by applying identity transformation.
                if animated {
                    UIView.animate(withDuration: 0.2) {
                        cardView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }
                } else {
                    cardView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
            if abs(distanceFromCenter) < cardSize.width / 2 {
                scrollView.bringSubviewToFront(cardView)
            }
        }
    }
}

