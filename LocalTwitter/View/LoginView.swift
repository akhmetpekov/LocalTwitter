//
//  LoginView.swift
//  LocalTwitter
//
//  Created by Erik on 29.12.2022.
//

import SwiftUI
import PhotosUI
import Firebase

//MARK: - LoginView
struct LoginView: View {
    //MARK: - User Details
    @State var emailID: String = ""
    @State var password: String = ""
    //MARK: - View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    var body: some View {
        VStack(spacing: 10){
            Text("Lets sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome Back, \nYou have been missed")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                TextField("email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                TextField("password", text: $password)
                    .textContentType(.password)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button(action: loginUser){
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                        .padding(.top, 10)
                }

            }
            
            //MARK: - Register Button
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Register Now"){
                    createAccount.toggle()
                }
                .foregroundColor(.black)
                .fontWeight(.bold)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        //MARK: - Register View VIA Sheets
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        //MARK: - Displaying Alert
        .alert(errorMessage, isPresented: $showError) {}
    }
    
    func loginUser(){
        Task{
            do{
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
            }catch{
                await setError(error)
            }
        }
    }
    
    func resetPassword() {
        Task{
            do{
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            }catch{
                await setError(error)
            }
        }
    }
    
    //MARK: - Displaying Errors VIA Alerts
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

//MARK: - RegisterView
struct RegisterView: View {
    //MARK: - User Detail
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    //MARK: - View Properties
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    var body: some View {
        VStack(spacing: 10){
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
            
            //MARK: - For Smaller Size Optimization
            ViewThatFits{
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                
                HelperView()
            }
            
            //MARK: - Register Button
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                
                Button("Login Now"){
                    dismiss()
                }
                .foregroundColor(.black)
                .fontWeight(.bold)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            //MARK: - Extracting UIImage From PhotoItem
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else {return}
                        
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                    } catch{}
                }
            }
        }
    }
    
    @ViewBuilder
    func HelperView()-> some View{
        VStack(spacing: 12) {
            ZStack{
                if let userProfilePicData, let image = UIImage(data: userProfilePicData){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top,25)

            TextField("username", text: $userName)
                .textContentType(.username)
                .border(1, .gray.opacity(0.5))
            
            TextField("email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("password", text: $password)
                .textContentType(.password)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (Optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            Button {
                
            } label: {
                Text("Sign in")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
                    .padding(.top, 10)
            }

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension View {
    //MARK: - Custom Horizontal Alignment
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    //MARK: - Custom Vertical Alignment
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    //MARK: - Custom Border
    func border(_ width: CGFloat,_ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    //MARK: - Custom Fill View With Padding
    func fillView(_ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}
