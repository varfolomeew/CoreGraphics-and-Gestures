//
//  ViewController.swift
//  FaceIt
//
//  Created by user on 3/6/18.
//  Copyright © 2018 Varfolomeew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var faceView: FaceView! {  //FaceView optional, потому что когда mvc загружается на экране впервые,этот outlet ещё не установлен(несколько наносекунд)
        didSet {
            //добавим recognizer который словит наш pinch и вызовет handler из FaceView
            let pinchRecognizer = UIPinchGestureRecognizer(target: faceView, action: #selector(faceView.changeScale(byReactingTo: )) )
            faceView.addGestureRecognizer(pinchRecognizer)   //ДОБАВИТЬ К АУТЛЕТУ РЕКОГНАЙЗЕР!
            //добавим recognizer который словит наш тап и вызовет метод toggleEyes
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleEyes(byReactingTo: )))
            tapRecognizer.numberOfTapsRequired = 1  //кол-во тапов
            faceView.addGestureRecognizer(tapRecognizer)
            //добавим recognizer который словит наш свайп и вызовет метод increaseHappiness
            let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(increaseHappiness))
            swipeUpRecognizer.direction = .up               //направление жеста вверх
            faceView.addGestureRecognizer(swipeUpRecognizer)
            //добавим recognizer который словит наш свайп и вызовет метод decreaseHappiness
            let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(decreaseHappiness))
            swipeDownRecognizer.direction = .down           //направление жеста вниз
            faceView.addGestureRecognizer(swipeDownRecognizer)
            
            updateUI()
        }
    }
    
    @objc func increaseHappiness()
    {
        expression = expression.happier
    }
    @objc func decreaseHappiness()
    {
        expression = expression.sadder
    }
    @objc func toggleEyes(byReactingTo tapRecognizer: UITapGestureRecognizer) { //открытие и закрытие глаз тапом(изменение expression)
        if tapRecognizer.state == .ended {
            let eyes: FacialExpression.Eyes = (expression.eyes == .closed) ? .open : .closed //выбор нового значения для eyes
            expression = FacialExpression(eyes: eyes, mouth: expression.mouth)               //присваиваем его модели, после чего updateUI()
        }
    }
    var expression = FacialExpression(eyes: .closed, mouth: .frown) {   //Главное Значение, которое на экране
        didSet {
            updateUI()                              //каждый раз,когда кто-то меняет нашу модель, мы вызываем функцию updateUI()
        }
    }
    
    
    private func updateUI()
    {
        switch expression.eyes {
        case .open:
            faceView?.eyesOpen = true                // связали expression(model) с булевой переменной из FaceView
        case .closed:
            faceView?.eyesOpen = false               //добираемся до значения через optional chaining, потому что может быть краш (@IBOutlet weak var faceView: FaceView! не в set на старте приложения)
        case .squinting:
            faceView?.eyesOpen = false
        }
        faceView?.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0 //булевая из view связана с значением из словаря ниже, если такого нет, то 0.0 значение
    }
    
    private let mouthCurvatures = [FacialExpression.Mouth.grin : 0.5, .frown : -1.0, .smile : 1.0, .neutral : 0.0, .smirk : -0.5] //dict настроений лица(из model) связанный с их значениями
}

