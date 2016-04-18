//
//  CountdownTimerView.swift
//  Rio
//
//  Created by Madhur Mohta on 11/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class CountdownTimerView: UIVisualEffectView {

    @IBOutlet weak var timerLabel : UILabel!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.timerLabel.font = UIFont(name: "HelveticaNeue", size: 30)
        self.timerLabel.textColor = UIColor.orangeColor()

        let dateComponents = NSDateComponents()
        dateComponents.day = 05;
        dateComponents.month = 8;
        dateComponents.year = 2016;
        dateComponents.hour = 14;
        dateComponents.minute = 30;
        dateComponents.second = 0;
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let openingCeremonyDate = calendar?.dateFromComponents(dateComponents)
        
        let countDownLabel = MZTimerLabel(label: self.timerLabel, andTimerType: MZTimerLabelTypeTimer)
        countDownLabel.frame = self.timerLabel.frame
        countDownLabel.setCountDownToDate(openingCeremonyDate)
        countDownLabel.timeFormat = "DD:HH:MM:ss"
        countDownLabel.start()
    }
    
//    timerExample3 = [[MZTimerLabel alloc] initWithLabel:_lblTimerExample3 andTimerType:MZTimerLabelTypeTimer];
//    [timerExample3 setCountDownTime:30*60];//** Or you can use [timer3 setCountDownToDate:aDate];
//    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
//    dateComponents.day = 05;
//    dateComponents.month = 8;
//    dateComponents.year = 2016;
//    dateComponents.hour = 14;
//    dateComponents.minute = 30;
//    dateComponents.second = 0;
//    NSCalendar * calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDate *date = [calendar dateFromComponents:dateComponents];
//    
//    [timerExample3 setCountDownToDate:date];
//    [timerExample3 setTimeFormat:  @"DD:HH:mm:ss"];
//    
//    [timerExample3 start];

}
