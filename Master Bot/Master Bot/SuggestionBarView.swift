//
//  SuggestionBarView.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 4. 29..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import UIKit

protocol SuggestionBarDelegate {
    var inputTextFieldValue: String {get set}
}

class SuggestionBarView: UIScrollView {
    
    var viewController: SuggestionBarDelegate?    // ViewController
    let BarHeight = 50.0
    var elements: [UIButton] = []
    var barlength: CGFloat = 0.0

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Drawing code
        // TODO: 초기화 부분 필요 -> 서치 알고리즘 초기화 기존 정보들 가져오기
        addElement(image: #imageLiteral(resourceName: "pizza"), name: "피자")
        addElement(image: #imageLiteral(resourceName: "weather"), name: "날씨")
        addElement(image: #imageLiteral(resourceName: "bus"), name: "버스")
        addElement(image: #imageLiteral(resourceName: "subway"), name: "지하철")
        self.contentSize = CGSize(width: barlength, height: 50)
        self.showsHorizontalScrollIndicator = false
    }
    
    // input string from InputTextFeild
    // TODO: 문자열 분석 알고리즘 필요 -> plist로 구현
    func search(input: String) {
        barlength = 0.0
        if input == "" {
            removeAllElements()
            addElement(image: #imageLiteral(resourceName: "pizza"), name: "피자")
            addElement(image: #imageLiteral(resourceName: "weather"), name: "날씨")
            addElement(image: #imageLiteral(resourceName: "bus"), name: "버스")
            addElement(image: #imageLiteral(resourceName: "subway"), name: "지하철")
        }
        else if input.contains("피자") {
            removeAllElements()
            addElement(name: "도미노")
            addElement(name: "피자헛")
            addElement(name: "파파존스")
        }
        else if input.contains("버스") {
            removeAllElements()
            addElement(name: "350")
            addElement(name: "340")
            addElement(name: "330")
        }
        else if input.contains("날씨") {
            removeAllElements()
            addElement(name: "오늘")
            addElement(name: "내일")
            addElement(name: "주간")
        }
        else if input.contains("피") {
            removeAllElements()
            addElement(image: #imageLiteral(resourceName: "pizza"), name: "피자")
        }
        else if input.contains("버") {
            removeAllElements()
            addElement(image: #imageLiteral(resourceName: "bus"), name: "버스")
        }
        else if input.contains("날") {
            removeAllElements()
            addElement(image: #imageLiteral(resourceName: "weather"), name: "날씨")
        }
        
        NSLog("Bar Length: " + String(describing: barlength))
        self.contentSize = CGSize(width: barlength, height: 50)
    }
    
    // Add suggestion element
    func addElement(image: UIImage? = nil, name: String) {
        let element = UIButton()
        let imageView = UIImageView(image: image)
        let label = UILabel()
        label.text = name
        label.sizeToFit()
        
        let ratio: Double!
        if let img = image {
            ratio = Double(img.size.width / img.size.height)
        } else {
            ratio = 0
        }
        
        element.addSubview(imageView)
        element.addSubview(label)
        self.addSubview(element)
        
        element.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Add image View constraints
        let imageViewLeftMargin = image == nil ? 0.0 : 8.0
        let imageViewDownSizeRatio = 0.8
        
        let imageViewLeftConstraint = makeConstraint(imageView, .left, element, .left, constant: imageViewLeftMargin)
        let imageViewHeightConstraint = makeConstraint(imageView, .height, element, .height, mutiplier: imageViewDownSizeRatio)
        let imageViewWidthConstraint = makeConstraint(imageView, .width, element, .height, mutiplier: ratio * imageViewDownSizeRatio)
        let imageViewPositionConstraint = makeConstraint(imageView, .centerY, element, .centerY)
        
        element.addConstraints([imageViewLeftConstraint, imageViewHeightConstraint, imageViewWidthConstraint, imageViewPositionConstraint])
        
        
        // Add label constraints
        let marginBetweenImageLabel = 10.0
        
        let labelLeftConstraint = makeConstraint(label, .left, imageView, .right, constant: marginBetweenImageLabel)
        let labelPositionConstraint = makeConstraint(label, .centerY, element, .centerY)
        
        element.addConstraints([labelLeftConstraint, labelPositionConstraint])
        
        
        // Add element constraints
        let marginBetweenElements = 10.0
        
        let elementLeftConstraint: NSLayoutConstraint!
        if elements.last != nil {
            elementLeftConstraint = makeConstraint(element, .left, elements.last, .right, constant: marginBetweenElements)
        } else {
            elementLeftConstraint = makeConstraint(element, .left, self, .left, constant: marginBetweenElements)
        }
        let elementWidth = Double(imageView.layoutMargins.left + label.frame.width) + Double(imageView.frame.width) * imageViewDownSizeRatio + Double(marginBetweenImageLabel)
        let elementWidthConstraint = makeConstraint(element, .width, constant: elementWidth)
        let elementHeightConstraint = makeConstraint(element, .height, constant: BarHeight)
        let elementPositionConstraint = makeConstraint(element, .centerY, self, .centerY)
        
        self.addConstraints([elementLeftConstraint, elementWidthConstraint, elementHeightConstraint, elementPositionConstraint])
        
        
        // borders for debug
        let borderWidth: CGFloat = 0
        
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = borderWidth
        
        label.layer.borderColor = UIColor.gray.cgColor
        label.layer.borderWidth = borderWidth
        
        element.layer.borderColor = UIColor.gray.cgColor
        element.layer.borderWidth = borderWidth
        
        // add Touch Event to element
        element.addTarget(self, action: #selector(self.elementTouchDownHandler(button:)), for: .touchDown)
        element.addTarget(self, action: #selector(self.elementTouchUpOutsideHandler(button:)), for: .touchUpOutside)
        element.addTarget(self, action: #selector(self.elementTouchUpInsideHandler(button:)), for: .touchUpInside)
        
        // Add element to elements array
        elements += [element]
        
        NSLog("element frame width: " + String(describing: element.frame.width))
        barlength += CGFloat(elementWidth) + CGFloat(marginBetweenElements)
    }
    
    // remove all the elements from elements
    func removeAllElements() {
        for element in elements {
            element.removeFromSuperview()
        }
        elements = []
    }
    
    // Touch Handler for elements
    func elementTouchDownHandler(button: UIButton) {
        button.backgroundColor = UIColor.gray
    }
    
    func elementTouchUpOutsideHandler(button: UIButton) {
        button.backgroundColor = UIColor.white
    }
    // TODO: 정리 필요!! - 텍스트의 자동완성된 부분을 수정해야함
    func elementTouchUpInsideHandler(button: UIButton) {
        button.backgroundColor = UIColor.white
        
        if let text = (button.subviews.last as! UILabel).text {
            if let input = viewController?.inputTextFieldValue {
                if let lastWord = input.components(separatedBy: " ").last {
                    if lastWord != "" && text.contains(lastWord) {
                        if let range = viewController?.inputTextFieldValue.range(of: lastWord) {
                            viewController?.inputTextFieldValue.removeSubrange(range)
                            if viewController?.inputTextFieldValue.characters.last == " " {
                                if let lastindex = viewController?.inputTextFieldValue.endIndex {
                                    viewController?.inputTextFieldValue.remove(at: lastindex)
                                }
                            }
                        }
                    }
                    viewController?.inputTextFieldValue += " " + text
                }
            }
        }
    }
    // make NSLayoutConstraint in short code
    func makeConstraint(_ item: Any, _ itemAttribute: NSLayoutAttribute, _ toItem: Any? = nil, _ toItemAttribute: NSLayoutAttribute = .notAnAttribute, mutiplier: Double = 1.0, constant: Double = 0.0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: itemAttribute, relatedBy: .equal, toItem: toItem, attribute: toItemAttribute, multiplier: CGFloat(mutiplier), constant: CGFloat(constant))
    }
}


