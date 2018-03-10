//
//  FaceView.swift
//  FaceIt
//
//  Created by user on 3/6/18.
//  Copyright © 2018 Varfolomeew. All rights reserved.
//

import UIKit
@IBDesignable                       //ЗАБРАСЫВАЕТ ВЕСЬ НАШ КОД В СТОРИБОРД
class FaceView: UIView
{
    // Public API
    
    @IBInspectable                  //ЗАБРАСЫВАЕТ scale(в этом случае)В АТРИБУТ ИНСПЕКТОР СТОРИБОРДА
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }  //скалирующая переменная для установки размера нашего черепа
    
    @IBInspectable
    var eyesOpen: Bool = true { didSet { setNeedsDisplay() } }      //глаза закрыты изначально
    
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } } //SETNEEDSDISPLAY для перерисовки нашего view каждый раз при изменении
    
    @IBInspectable
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }  //никога не вызывай главный метод draw()
    
    @IBInspectable
    var mouthCurvature: Double = -0.5 { didSet { setNeedsDisplay() } }  //1.0 is full smile and -1.0 is full frown
    
    
    @objc func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer)        //handler скалирования всей картинки
    {
        switch pinchRecognizer.state {
        case .changed, .ended:              //если пинч меняется или закончил меняться, то scale равен предыдущее_значение*pinchRecognizer.scale
            self.scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1       //ставим множитель изначально равным единице, чтобы он не сохранялся каждый раз
        default:
            break
        }
    }
    
    //  Private Implementation
    
    private struct Ratios {             //создаём константы для размещения глаз и рта отдельно и сгрупированно
        static let skullRadiusToEyeOffset: CGFloat = 3
        static let skullRadiusToEyeRadius: CGFloat = 10
        static let skullRadiusToMouthWidth: CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
        static let skullRadiusToMouthOffset: CGFloat = 3
    }

    private var skullRadius: CGFloat {
        return  min(bounds.size.width, bounds.size.height) / 2  * scale   //задаём радиус черепа
    }
    private var skullCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)            //задаём центр черепа
    }
    private enum Eye {              //тип данных для создания и разграничения правого и левого глаза
        case left
        case right
    }
    
    
    
    private func pathForEye(_ eye: Eye) -> UIBezierPath     //path наших глаз
    {
       //будет использоваться только здесь, поэтому и кидаем в pathForEye
        func centerOfEye(_ eye: Eye) -> CGPoint {                            //получаем центры глаз
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset                                    //поднимаем глаза вверх на eyeOffset от цента
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset        //размещаем глаза левее и правее центра
            return eyeCenter
        }
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius     //радиус глаза
        let eyeСenter = centerOfEye(eye)                                //радиус глаза из параметра функции pathForEye
        
        let path: UIBezierPath         //создаём константу и сразу же ниже реализовываем её в разных случаях уже без let
        if eyesOpen {
            path = UIBezierPath(arcCenter: eyeСenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)  //рисуем path ОТКРЫТЫХ глаз
        } else {
            path = UIBezierPath()               //рисуем path ЗАКРЫТЫХ глаз
            path.move(to: CGPoint(x: eyeСenter.x - eyeRadius, y: eyeСenter.y))      //размещаем глаза
            path.addLine(to: CGPoint(x: eyeСenter.x + eyeRadius, y: eyeСenter.y))   //рисуем линии глаз
        }
        path.lineWidth = lineWidth        //толщина глаз
        return path
    }
    
    
    
    
    private func pathForMouth() -> UIBezierPath     //path нашего рта
    {
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth           //ширина рта
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight         //высота рта
        let mouthOffset = skullRadius / Ratios.skullRadiusToMouthOffset         //изменение положения рта
        
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth / 2,               //рисуем прямоугольник рта
                               y: skullCenter.y + mouthOffset,
                               width: mouthWidth,
                               height: mouthHeight
        )
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height    //изменение улыбки
        
        
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)         //стартовая точка кривой Безье
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)           //конечная точка кривой Безье
    
        let cp1 = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)     //1ая контрольная точка кривой Безье
        let cp2 = CGPoint(x: end.x - mouthRect.width / 3, y: start.y + smileOffset)       //2ая контрольая точка кривой Безье
        
        
        
        
        let path = UIBezierPath()                //забрасываем нарисованный rect рта в path(СДЕЛАЛИ НЕВИДИМЫМ)
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)  //рисуем кривую Безье
        
        path.lineWidth = lineWidth                      //толщина кривой Безье
        
        return path
    }
    
    
    private func pathForSkull() -> UIBezierPath     //path нашего черепа
    {   let path = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false) //рисуем дугу в 2 * Pi градусов, т.е. целый круг
        path.lineWidth = lineWidth                //толщина линиии
        return path
    }
    
    
    override func draw(_ rect: CGRect) {    //---------ГЛАВНЫЙ МЕТОД РИСОВАНИЯ------
        color.set()                  //установка цвета
        pathForSkull().stroke()             //заброс черепа на экран
        pathForEye(.left).stroke()          //заброс левого глаза
        pathForEye(.right).stroke()         //заброс правого глаза
        pathForMouth().stroke()             //заброс рта на экран
        
    }
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
