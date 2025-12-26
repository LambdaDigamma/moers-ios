//
//  Shadows.swift
//  Core
//
//  Created by Lennart Fischer on 07.11.25.
//

import SwiftUI


// MARK: - shadow-2xs
struct Shadow2xsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.05), radius: 0, x: 0, y: 1)
    }
}

// MARK: - shadow-xs
struct ShadowXsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - shadow-sm
struct ShadowSmModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - shadow-md
struct ShadowMdModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - shadow-lg
struct ShadowLgModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 10)
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
    }
}

// MARK: - shadow-xl
struct ShadowXlModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.1), radius: 25, x: 0, y: 20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 8)
    }
}

// MARK: - shadow-2xl
struct Shadow2xlModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.25), radius: 50, x: 0, y: 25)
    }
}

extension View {
    public func shadow2XS() -> some View { modifier(Shadow2xsModifier()) }
    public func shadowXS() -> some View { modifier(ShadowXsModifier()) }
    public func shadowSM() -> some View { modifier(ShadowSmModifier()) }
    public func shadowMD() -> some View { modifier(ShadowMdModifier()) }
    public func shadowLG() -> some View { modifier(ShadowLgModifier()) }
    public func shadowXL() -> some View { modifier(ShadowXlModifier()) }
    public func shadow2XL() -> some View { modifier(Shadow2xlModifier()) }
}

private struct ShadowPreviewContainer: View {
    
    let title: String
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white)
            .aspectRatio(CGSize(width: 4, height: 2), contentMode: .fit)
            .overlay {
                Text(title)
            }
            .clipped()
        
    }
    
}

#Preview {
    
    ScrollView {
        
        VStack(spacing: 40) {
            
            ShadowPreviewContainer(title: "Shadow 2XS")
                .shadow2XS()
                .padding(.horizontal)
            
            ShadowPreviewContainer(title: "Shadow XS")
                .shadowXS()
                .padding(.horizontal)
            
            ShadowPreviewContainer(title: "Shadow SM")
                .shadowSM()
                .padding(.horizontal)
            
            ShadowPreviewContainer(title: "Shadow MD")
                .shadowMD()
                .padding(.horizontal)
            
            ShadowPreviewContainer(title: "Shadow LG")
                .shadowLG()
                .padding(.horizontal)
            
            ShadowPreviewContainer(title: "Shadow XL")
                .shadowXL()
                .padding(.horizontal)
            
            ShadowPreviewContainer(title: "Shadow 2XL")
                .shadow2XL()
                .padding(.horizontal)
            
        }
        .padding(.vertical, 80)
            
    }
    .background {
        Color(UIColor.secondarySystemBackground)
            .ignoresSafeArea()
    }
    
}
