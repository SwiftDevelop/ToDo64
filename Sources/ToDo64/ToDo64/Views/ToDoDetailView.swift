//
//  ToDoDetailView.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import SwiftUI
import SwiftData

struct ToDoDetailView: View {
    // MARK: - Properties
    
    let item: ToDoItem
    @Environment(\.dismiss) private var dismiss
    
    // ViewModel
    @State private var viewModel: ToDoDetailViewModel
    
    // Focus State (View 전용 UI 상태)
    @FocusState private var isContentFocused: Bool
    
    // MARK: - Initialization
    
    init(item: ToDoItem, modelContext: ModelContext) {
        self.item = item
        // ViewModel을 init 시점에 바로 생성하여 뷰 진입 시 레이아웃 점프 현상 방지
        let vm = ToDoDetailViewModel(item: item, modelContext: modelContext)
        _viewModel = State(initialValue: vm)
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView(viewModel)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func contentView(_ viewModel: ToDoDetailViewModel) -> some View {
        // FIXME: 뷰의 계층이 깊어 가독성이 떨어질 수 있으니 섹션별로 별도 뷰로 분리 권장
        ScrollViewReader { proxy in
            Form {
                // 1. 타이틀 섹션
                Section {
                    TextField("제목을 입력하세요", text: Bindable(viewModel).localTitle)
                        .font(.body)
                        .onChange(of: viewModel.localTitle) { oldValue, newValue in
                            viewModel.validateTitleInput()
                        }
                } header: {
                    Text("할 일")
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(viewModel.localTitle.count) / \(ToDoConstants.Limits.titleMaxLength)")
                            .font(.caption)
                            .foregroundColor(viewModel.localTitle.count >= ToDoConstants.Limits.titleMaxLength ? .red : .secondary)
                    }
                }
                
                // 2. 상세 메모 섹션
                Section {
                    TextField("상세 내용을 입력하세요", text: Bindable(viewModel).localContent, axis: .vertical)
                        .focused($isContentFocused)
                        .id("memoField")
                        .frame(minHeight: 44, alignment: .top)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isContentFocused = true
                        }
                        .onChange(of: viewModel.localContent) { oldValue, newValue in
                            viewModel.validateContentInput()
                            
                            // 줄바꿈 발생 시 스크롤
                            let oldLines = oldValue.filter({ $0 == "\n" }).count
                            let newLines = newValue.filter({ $0 == "\n" }).count
                            
                            if newLines > oldLines {
                                withAnimation {
                                    proxy.scrollTo("memoField", anchor: .bottom)
                                }
                            }
                        }
                } header: {
                    Text("상세 메모")
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(viewModel.localContent.count) / \(ToDoConstants.Limits.contentMaxLength)")
                            .font(.caption)
                            .foregroundColor(viewModel.localContent.count >= ToDoConstants.Limits.contentMaxLength ? .red : .secondary)
                    }
                }
                
                // 3. 옵션 섹션
                Section {
                    Toggle("완료 처리", isOn: Bindable(viewModel).localIsCompleted)
                    Toggle("알림 받기", isOn: Bindable(viewModel).localIsReminderOn)
                    
                    if viewModel.localIsReminderOn {
                        DatePicker(
                            "알림 시간",
                            selection: Bindable(viewModel).localReminderDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                } header: {
                    Text("설정")
                }
                
                // 4. 정보 섹션
                Section {
                    HStack {
                        Text("생성일")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(item.createdAt, format: .dateTime)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("정보")
                }
            }
            .navigationTitle("상세 정보")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                hideKeyboard()
            }
            .toolbar {
                // 커스텀 네비게이션 버튼 제거 (시스템 버튼 사용)
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 16) {
                    Button {
                        if viewModel.saveChanges() {
                            dismiss()
                        }
                    } label: {
                        Text("저장하기")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                    
                    Button {
                        viewModel.showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .padding(.top, 10)
            }
            .alert("할 일 삭제", isPresented: Bindable(viewModel).showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    viewModel.deleteItem()
                    dismiss()
                }
            } message: {
                Text("정말로 이 할 일을 삭제하시겠습니까?")
            }
            .alert("제목 입력 필요", isPresented: Bindable(viewModel).showEmptyTitleAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("할 일 제목은 비워둘 수 없습니다.")
            }
            .onChange(of: isContentFocused) { oldValue, newValue in
                if newValue {
                    withAnimation {
                        proxy.scrollTo("memoField", anchor: .center)
                    }
                }
            }
        }
    }
}

