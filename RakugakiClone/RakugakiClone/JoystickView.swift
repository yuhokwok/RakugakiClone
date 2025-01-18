//
//  JoystickView.swift
//  RakugakiClone
//
//  Created by Yu Ho Kwok on 1/17/25.
//


import SwiftUI

struct JoystickView: View {
    @State private var knobOffset: CGSize = .zero
    let maxRadius: CGFloat = 40
    
    /// Callback that receives x,y in the range [-1...1].
    /// For example, (x: 1, y: 0) means full right; (x: 0, y: -1) means full up, etc.
    var onChange: (CGFloat, CGFloat) -> Void
    
    var body: some View {
        GeometryReader { geo in
            let baseRadius = min(geo.size.width, geo.size.height) / 2
            ZStack {
                // Base circle
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: baseRadius * 2, height: baseRadius * 2)
                
                // Knob (draggable)
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 40, height: 40)
                    .offset(x: knobOffset.width, y: knobOffset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateKnob(withDragValue: value, baseRadius: baseRadius)
                            }
                            .onEnded { _ in
                                // Snap back to center
                                withAnimation(.spring()) {
                                    knobOffset = .zero
                                }
                                onChange(0, 0)
                            }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    /// Update the knob offset (and call onChange) as the user drags.
    private func updateKnob(withDragValue value: DragGesture.Value, baseRadius: CGFloat) {
        // Proposed new offset
        let dx = value.translation.width
        let dy = value.translation.height
        
        let distance = sqrt(dx * dx + dy * dy)
        if distance > maxRadius {
            let angle = atan2(dy, dx)
            let clampedX = cos(angle) * maxRadius
            let clampedY = sin(angle) * maxRadius
            knobOffset = CGSize(width: clampedX, height: clampedY)
        } else {
            knobOffset = value.translation
        }
        
        // Normalize to [-1...1]
        let normX = knobOffset.width / maxRadius
        let normY = knobOffset.height / maxRadius
        
        // Pass these to onChange
        onChange(normX, normY)
        
        print("\(normX) \(normY)")
    }
}


#Preview {
    
    JoystickView(onChange: {
        x, y in
        print("x:\(x), y: \(y)")
    })
    .frame(width: 150, height: 150)
    
}
