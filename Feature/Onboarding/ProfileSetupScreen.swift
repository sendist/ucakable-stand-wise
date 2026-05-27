//
//  ProfileSetupScreen.swift
//  StandWise
//
//  Created by Sendi Setiawan on 27/05/26.
//

import SwiftUI
import EventKit
import HealthKit
import PhotosUI
import SwiftUI
import SwiftData
import UIKit

struct ProfileSetupScreen: View {
    let name: String
    let profileImageData: Data?
    var onContinue: (String, Data?) -> Void = { _, _ in }
    var onSkip: () -> Void = {}

    @State private var draftName: String
    @State private var draftImageData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)

    init(
        name: String,
        profileImageData: Data?,
        onContinue: @escaping (String, Data?) -> Void = { _, _ in },
        onSkip: @escaping () -> Void = {}
    ) {
        self.name = name
        self.profileImageData = profileImageData
        self.onContinue = onContinue
        self.onSkip = onSkip
        _draftName = State(initialValue: name)
        _draftImageData = State(initialValue: profileImageData)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 20)

                VStack(spacing: 10) {
                    Text("Set up your profile")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text("Add a name and picture for your dashboard.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                profilePhotoPicker

                TextField("Name", text: $draftName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    }

                Spacer(minLength: 16)

                VStack(spacing: 14) {
                    Button {
                        onContinue(draftName, draftImageData)
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(brandGreen)

                    Button("Skip for Now", action: onSkip)
                        .buttonStyle(.plain)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .onChange(of: selectedPhoto) {
            loadSelectedPhoto()
        }
    }

    private var profilePhotoPicker: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                profilePhoto

                Image(systemName: "camera.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(brandGreen, in: Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(Color(.systemBackground), lineWidth: 3)
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoadingPhoto)
        .accessibilityLabel("Choose profile picture")
    }

    @ViewBuilder
    private var profilePhoto: some View {
        if isLoadingPhoto {
            ProgressView()
                .frame(width: 128, height: 128)
                .background(brandGreen.opacity(0.10), in: Circle())
        } else if let draftImageData,
                  let uiImage = UIImage(data: draftImageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 128, height: 128)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                }
        } else {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 118))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(brandGreen)
                .frame(width: 128, height: 128)
        }
    }

    private func loadSelectedPhoto() {
        guard let selectedPhoto else {
            return
        }

        isLoadingPhoto = true

        Task {
            defer {
                Task { @MainActor in
                    isLoadingPhoto = false
                }
            }

            guard let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                  let resizedData = resizedJPEGData(from: data) else {
                return
            }

            await MainActor.run {
                draftImageData = resizedData
            }
        }
    }

    private func resizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        let maxLength: CGFloat = 512
        let scale = min(maxLength / max(image.size.width, image.size.height), 1)
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resizedImage.jpegData(compressionQuality: 0.82)
    }
}

#Preview("profile-setup") {
    ProfileSetupScreen(
        name: "User",
        profileImageData: nil,
        onContinue: {_,_ in },
        onSkip: {}
    )
}
