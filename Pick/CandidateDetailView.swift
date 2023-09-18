//
//  CandidateDetailView.swift
//  Pick
//
//  Created by Mashrafi Rahman on 3/9/23.
//

import SwiftUI
import WrappingHStack

/// Detailed view of Candidate.
struct CandidateDetailView: View {
    @Binding var candidate: Candidate
    @State private var foreground: Color = .init(uiColor: .systemBackground)
    @State private var imageColor: Color = .init(uiColor: .systemBackground)
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    AsyncImage(url: candidate.pict) { img in
                        img
                            .resizable()
                            .scaledToFill()
                            .frame(height: geometry.size.height / 2, alignment: .top)
                            .clipped()
                            .overlay(alignment: .bottomLeading) {
                                Text(candidate.name)
                                    .foregroundStyle(foreground)
                                    .font(.largeTitle)
                                    .bold()
                                    .padding()
                            }
                            .onAppear {
                                guard let c = self.getAverageColor(image: img) else { return }
                                imageColor = Color(red: c.0, green: c.1, blue: c.2, opacity: c.3)
                                foreground = .init(contrasting: c)
                            }
                    } placeholder: {
                        ProgressView()
                            .padding()
                    }
                    .frame(height: geometry.size.height / 2)
                    
                    ScrollView {
                        VStack {
                            Text(candidate.desc + "\n").font(.headline) + Text(candidate.about)
                        }
                        .foregroundStyle(foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                        WrappingHStack(alignment: .leading) {
                            ForEach(candidate.social) { handle in
                                HandleView(handle: handle)
                                    .frame(height: 26)
                                    .buttonStyle(.borderedProminent)
                                    .padding(.vertical, 5)
                            }
                            
                            if let wiki = candidate.wiki {
                                HandleView(handle: .init(wiki: wiki))
                                    .frame(height: 26)
                                    .buttonStyle(.borderedProminent)
                                    .padding(.vertical, 5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 150)
                    }
                    .safeAreaPadding(.bottom)
                }
            }
            .ignoresSafeArea()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.title2)
                    .foregroundStyle(foreground)
                    .opacity(0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            
            Stepper(value: $candidate.rate, in: 1...5) {
                RatingView(rating: $candidate.rate, max: 5)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10)
            .padding()
        }
        .background(imageColor)
        .navigationBarBackButtonHidden()
        .toolbarBackground(imageColor, for: .tabBar)
        .onBackSwipe {
            dismiss()
        }
    }
    
    /*
     Reference:
     https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
     */
    @MainActor private func getAverageColor(image: Image) -> (CGFloat, CGFloat, CGFloat, CGFloat)? {
        let renderer: ImageRenderer = .init(content: image)
        let uiimg: UIImage? = renderer.uiImage
        guard let uiimg, let img: CIImage = .init(image: uiimg) else { return nil }
        let vec: CIVector = .init(x: img.extent.origin.x,
                                  y: img.extent.origin.y,
                                  z: img.extent.size.width,
                                  w: img.extent.size.height)
        
        let filter: CIFilter? = .init(
            name: "CIAreaAverage",
            parameters: [kCIInputImageKey: img, kCIInputExtentKey: vec]
        )
        guard let filter, let img = filter.outputImage else { return nil }
        
        var bitmap: [UInt8] = .init(repeating: 0, count: 4)
        let context: CIContext = .init(options: [.workingColorSpace: kCFNull!])
        context.render(
            img,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: .init(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        
        return (
            CGFloat(bitmap[0]) / 255, // red
            CGFloat(bitmap[1]) / 255, // green
            CGFloat(bitmap[2]) / 255, // blue
            CGFloat(bitmap[3]) / 255  // alpha
        )
    }
}

// Reference: https://stackoverflow.com/a/72920145/19434087
extension View {
    func onBackSwipe(perform action: @escaping () -> Void) -> some View {
        gesture (
            DragGesture()
                .onEnded { value in
                    if value.startLocation.x < 50 && value.translation.width > 80 {
                        action()
                    }
                }
        )
    }
}

extension Color {
    /*
     Reference:
     https://dallinjared.medium.com/swiftui-tutorial-contrasting-text-over-background-color-2e7af57c1b20
     */
    init(contrasting color: (CGFloat, CGFloat, CGFloat, CGFloat)) {
        let luminance: CGFloat = 0.2126 * color.0 + 0.7152 * color.1 + 0.0722 * color.2
        self = luminance < 0.6 ? .white : .black
    }
    
    func darker() -> Color {
        return Color(UIColor(self).darker())
    }
}

// Reference: https://www.advancedswift.com/lighter-and-darker-uicolor-swift/
extension UIColor {
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
    
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
    
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
}

struct CandidateDetailViewPreview: View {
    @State private var candidate: Candidate = Election.demo.first!
    
    var body: some View {
        CandidateDetailView(candidate: $candidate)
    }
}

#Preview {
    CandidateDetailViewPreview()
}
