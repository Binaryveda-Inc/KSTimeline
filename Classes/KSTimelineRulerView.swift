//
//  KSTimelineRulerView.swift
//  KSTimeline
//
//  Created by Shih on 24/11/2017.
//  Copyright © 2017 kenshih. All rights reserved.
//

import UIKit

@objc protocol KSTimelineRulerEventDataSource: NSObjectProtocol {
    
    func numberOfEvents(_ ruler: KSTimelineRulerView) -> Int
    
    func timelineRuler(_ ruler: KSTimelineRulerView, eventAt index: Int) -> KSTimelineEvent

}

@IBDesignable open class KSTimelineRulerView: UIView {
    
    var dataSource: KSTimelineRulerEventDataSource?
    
    public var filterType: RulerFilter = .motionDetection
    
    var drawWave: Bool = false {
        
        didSet {
            
            self.setNeedsDisplay()
            
        }
        
    }
    
    var isDisabled = false
    
    internal func drawEvent(rect: CGRect) {
        
        guard let dataSource = self.dataSource else { return }
                
        let numberOfEvents = dataSource.numberOfEvents(self)
        
        let padding = UIScreen.main.widthOfSafeArea()
        
        let contentWidth = self.bounds.width - padding
                
        let unit_hour_width = contentWidth / 24
        
        let unit_minute_width = unit_hour_width / 60
        
        let unit_second_width = unit_minute_width / 60
        
        let unit_gap_height = CGFloat(20)
        
        let wave_height = CGFloat(5)
        
        for index in 0..<numberOfEvents {
            
            let event = dataSource.timelineRuler(self, eventAt: index)
            
            let start_hour = Calendar.current.component(.hour, from: event.start)
            
            let start_minute = Double(Calendar.current.component(.minute, from: event.start))
            
            let start_second = Double(Calendar.current.component(.second, from: event.start))
            
            let end_hour = Calendar.current.component(.hour, from: event.end)
            
            let end_minute = Double(Calendar.current.component(.minute, from: event.end))
            
            let end_second = Double(Calendar.current.component(.second, from: event.end))
            
            let start_x = (unit_hour_width * CGFloat(start_hour)) + (unit_minute_width * CGFloat(start_minute)) + (unit_second_width * CGFloat(start_second)) + (padding / 2)

            let end_x = (unit_hour_width * CGFloat(end_hour)) + (unit_minute_width * CGFloat(end_minute)) + (unit_second_width * CGFloat(end_second)) + (padding / 2)
            if(self.isDisabled){
                UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 199.0/255.0, alpha: 1.0).setFill()
            }else{
                switch(filterType){
                    case .motionDetection:
                        UIColor(red: 123.0/255.0, green: 176.0/255.0, blue: 241.0/255.0, alpha: 1.0).setFill()
                    case .continuous:
                        UIColor(red: 248.0/255.0, green: 219.0/255.0, blue: 158.0/255.0, alpha: 1.0).setFill()
                }
            }
            
            UIRectFill(CGRect(x: start_x, y: rect.size.height - 48.0 - unit_gap_height, width: end_x - start_x, height: 48.0))
            
        }
        
    }

    override open func draw(_ rect: CGRect) {

        super.draw(rect)
        
        let padding = UIScreen.main.widthOfSafeArea()

        let contentWidth = self.bounds.width - padding

        let unit_hour_width = contentWidth / 24

        let unit_minute_width = unit_hour_width / 6

        let unit_second_width = unit_minute_width / 5

        let unit_hour_height = self.bounds.height / 2

        let unit_minute_height = unit_hour_height / 2

//        let unit_sec_height = unit_minute_height / 2
        
        let unit_sec_height = CGFloat(48.0)

        let show_hour = unit_hour_width > 10 ? true : false

        let show_minute = unit_minute_width > 10 ? true : false

        let show_second = unit_second_width > 20 ? true : false

        let unit_gap_height = CGFloat(20)

        let extra_padding = padding / 2
        
        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
        ]
        
        let text_width = CGFloat(36)
        
        let text_height = CGFloat(12)
        if(self.isDisabled){
            UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 0.7).setFill()
        }else{
            switch(filterType){
                case .motionDetection:
                    UIColor(red: 215.0/255.0, green: 231.0/255.0, blue: 247.0/255.0, alpha: 0.7).setFill()
                case .continuous:
                    UIColor(red: 250.0/255.0, green: 234.0/255.0, blue: 200.0/255.0, alpha: 0.7).setFill()
            }
        }
        UIRectFill(CGRect(x: 0, y: rect.size.height - unit_sec_height - unit_gap_height, width: rect.size.width , height: 48.0))

        if show_hour == true {

            for hour in 0...23 {

                let hour_x = CGFloat(hour) * unit_hour_width + extra_padding

                let hour_y = rect.size.height - unit_sec_height

                UIColor.lightGray.setFill()

                UIRectFill(CGRect(x: hour_x, y: hour_y - unit_gap_height, width: 1, height: unit_sec_height))
                
                let text_x = hour_x - (text_width / 2)

                let text_y = rect.size.height - 14.0

                (String(format: "%02d:00", hour) as NSString).draw(in: CGRect(x: text_x, y: text_y, width: text_width, height: text_height), withAttributes: textFontAttributes)

                if show_minute == true {

                    for minute in 0..<6 {

                        let minute_x = CGFloat(minute) * unit_minute_width

                        let minute_y = rect.size.height - unit_minute_height

                        if show_second == true {

                            for second in 0..<5 {

                                let second_x = CGFloat(second) * unit_second_width

                                let second_y = rect.size.height - unit_sec_height

                                UIColor.lightGray.setFill()

                                UIRectFill(CGRect(x: hour_x + minute_x + second_x, y: hour_y - unit_gap_height, width: 1, height: unit_sec_height))

                            }

                        }
                        
                        if unit_minute_width > text_width {
                            
                            UIColor.lightGray.setFill()

                            UIRectFill(CGRect(x: hour_x + minute_x, y: hour_y - unit_gap_height, width: 1, height: unit_sec_height))
                            
                            let text_x = hour_x + minute_x - (text_width / 2)
                            
                            let text_y = rect.size.height - 14.0
                            
//                            DispatchQueue.main.async {
                                (String(format: "%02d:%02d", hour, minute*10) as NSString).draw(in: CGRect(x: text_x, y: text_y, width: text_width, height: text_height), withAttributes: textFontAttributes)
//                            }
                            
                        }

                    }

                }

            }

//            UIColor.white.setFill()
//
//            UIRectFill(CGRect(x: extra_padding, y: 0, width: rect.size.width - extra_padding*2, height: 0.5))
//
//            UIRectFill(CGRect(x: extra_padding, y: rect.size.height - 20, width: rect.size.width - extra_padding*2, height: 0.5))

        }
        
        if self.drawWave {
            
            self.drawEvent(rect: rect)
            
        }
        
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clear
                
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    override open func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        
    }
    
    public func disableView(){
        self.isDisabled = true
        self.layoutSubviews()
    }
    
    public func enableView(){
        self.isDisabled = false
        self.layoutSubviews()
    }

}
