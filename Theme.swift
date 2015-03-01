//
//  Theme.swift
//  AnyRead
//
//  Created by wuhanchu on 15/2/6.
//  Copyright (c) 2015年 wuhanchu. All rights reserved.
//

import Foundation
struct Theme{
    static var currentTheme = ThemeType.dayTheme
    static var backgroundColor = UIColor.whiteColor()
    static var titleColor = UIColor.blackColor()
    static var annotateColor = UIColor.grayColor()
    static var sepratorColor = UIColor.grayColor()
    static var titleFont = UIFont.systemFontOfSize(14)
    static var annotateFont = UIFont.systemFontOfSize(12)
    static var cellGroundColor = UIColor.whiteColor()
    static var sectionBackgroundColor = UIColor.clearColor()
    
    

    static func changeTheme(theme: ThemeType){
        switch(theme){
        case ThemeType.dayTheme:
            dayTheme()
        case ThemeType.nightTheme:
            nightTheme()
        }
    }

    static func nightTheme(){
        currentTheme = ThemeType.nightTheme
        backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
     
        cellGroundColor = UIColor(red:0.33 ,green:0.37, blue:0.42, alpha:0.8)
        titleColor = UIColor.whiteColor()
        annotateColor = UIColor.orangeColor()
        sepratorColor = UIColor.clearColor()
    }
    
    static func dayTheme(){
        currentTheme = ThemeType.dayTheme
        backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        sectionBackgroundColor = UIColor.clearColor()
        cellGroundColor = UIColor.whiteColor()
        sepratorColor = UIColor.clearColor()
        titleColor = UIColor.blackColor()
        annotateColor =  UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.9)
    }
    
    static func drawTableView(tableView: UITableView){
        tableView.backgroundColor = backgroundColor
        tableView.separatorColor = sepratorColor
        tableView.sectionIndexColor = annotateColor
    }
    
    static func  drawCell(cell: UITableViewCell!){
        cell.backgroundColor = cellGroundColor
        cell.textLabel?.font = titleFont
        cell.textLabel?.textColor = titleColor
        cell.detailTextLabel?.font = annotateFont
        cell.detailTextLabel?.textColor = annotateColor
    }
}

enum ThemeType:Int{
    case dayTheme = 1
    case nightTheme = 2
}