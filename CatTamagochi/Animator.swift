//
//  Animator.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 12.09.2024.
//

import Foundation
import FastAppLibrary

class Animator {
    // animations
    enum CatAnimations: String, CaseIterable {
        case idle = "idle"
        case dead = "dead"
        case talk = "talk"
        case eat = "eat"
        case engry = "engry"
        case evil = "evil"
        case happy = "happy"
        case hunt = "hunt"
        case medicine = "medicine"
        case play = "play"
    }

    private let animationExt: String = "mp4"
    
    public var videoPlayer: LoopPlayerView
    public var animationController: LoopingPlayerUIView
    
    private var currentAnimation: CatAnimations = .idle
    private var idleAnimation: CatAnimations = .idle
    
    init() {
        animationController = LoopingPlayerUIView(
            currentAnimation.rawValue,
            width: animationExt,
            gravity: .resizeAspectFill
        )!
        self.videoPlayer = LoopPlayerView(view: animationController)
        
        animationController.onAnimationFinish = {
            if self.currentAnimation != self.idleAnimation {
                self.currentAnimation = self.idleAnimation
                self.play(self.idleAnimation)
            }
        }
    }
    
    func setIdle(_ animation: CatAnimations){
        idleAnimation = animation
        play(animation)
    }
    
    func play(_ animation: CatAnimations) {
        currentAnimation = animation
        animationController.replace(name: animation.rawValue)
    }
    
}
