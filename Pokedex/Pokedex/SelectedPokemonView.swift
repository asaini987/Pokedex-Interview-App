//
//  SelectedPokemonView.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/27/25.
//

import SwiftUI

struct SelectedPokemonView: View {
    let detail: PokemonDetail?
    @State private var isAnimating = false
    @State private var imageScale: CGFloat = DrawingConstants.initialScale
    
    var body: some View {
        VStack {
            if let detail {
                if let spriteURL = detail.sprites.frontDefault,
                   let url = URL(string: spriteURL) {
                    CachedAsyncImage(url: url)
                        .id(url)
                        .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
                        .shadow(radius: DrawingConstants.shadowRadius)
                        .scaleEffect(imageScale)
                        .onAppear { startAnimations() }
                        .offset(y: isAnimating ? -DrawingConstants.bounceOffset : 0)
                } else {
                    Image(systemName: "questionmark.square.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                        .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
                        .shadow(radius: DrawingConstants.shadowRadius)
                        .scaleEffect(imageScale)
                        .offset(y: isAnimating ? -DrawingConstants.bounceOffset : 0)
                        .onAppear { startAnimations() }
                }
                
                Text(detail.name.capitalized)
                    .font(.title2.weight(.semibold))
                    .transition(.scale.combined(with: .opacity))

            } else {
                VStack {
                    pokeBall
                        .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
                        .onAppear { startAnimations() }
                        .offset(y: isAnimating ? -DrawingConstants.bounceOffset : 0)
                    
                    Text("Tap a Pokémon")
                        .foregroundStyle(.secondary)
                        .padding(.top)
                        .transition(.opacity)
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: DrawingConstants.minHeight,
            maxHeight: DrawingConstants.maxHeight
        )
        .padding()
        .onChange(of: detail) { _, newValue in
            if newValue != nil {
                imageScale = DrawingConstants.initialScale
                isAnimating = false
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: DrawingConstants.springResponse,
                              dampingFraction: DrawingConstants.springDamping)) {
            imageScale = DrawingConstants.finalScale
        }
        withAnimation(.easeInOut(duration: DrawingConstants.bounceDuration)
            .repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
    
    private var pokeBall: some View {
        ZStack {
            Circle()
                .fill(.red)
            
            Circle()
                .trim(from: DrawingConstants.trimStart, to: DrawingConstants.trimEnd)
                .fill(.white)
                .rotationEffect(.degrees(DrawingConstants.rotationEffect))
            
            Circle()
                .stroke(.black, lineWidth: DrawingConstants.outerRingLineWidth)
            
            HStack {
                Rectangle()
                    .fill(.black)
                    .frame(height: DrawingConstants.bandHeight)
                
                Spacer()
                
                Rectangle()
                    .fill(.black)
                    .frame(height: DrawingConstants.bandHeight)
            }
            
            Circle()
                .fill(.white)
                .overlay(
                    Circle()
                        .stroke(.black, lineWidth: DrawingConstants.innerRingLineWidth)
                )
                .scaleEffect(DrawingConstants.scaleEffect)
        }
        .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
    }
    
    private struct DrawingConstants {
        // Pokemon image
        static let aspectRatio: CGFloat = 1
        static let shadowRadius: CGFloat = 6
        static let minHeight: CGFloat = 220
        static let maxHeight: CGFloat = 240
        
        // Animation
        static let bounceOffset: CGFloat = 8
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.6
        static let bounceDuration: Double = 2.0
        static let initialScale: CGFloat = 0.8
        static let finalScale: CGFloat = 1.0
        
        // Pokéball
        static let rotationEffect: Double = 180
        static let outerRingLineWidth: CGFloat = 4
        static let innerRingLineWidth: CGFloat = 20
        static let scaleEffect: CGFloat = 0.25
        static let trimStart: CGFloat = 0.5
        static let trimEnd: CGFloat = 1.0
        static let bandHeight: CGFloat = 7
        static let bandSpacerWidth: CGFloat = 0.5
    }
}

#Preview {
    SelectedPokemonView(detail: nil)
}
