//
//  ToDoListView.swift
//  ToDo64
//
//  Created by SwiftDevelop on 2026/01/07.
//

import SwiftUI
import SwiftData

struct ToDoListView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDoItem.createdAt, order: .reverse) private var items: [ToDoItem]
    
    // ViewModel (State로 관리)
    @State private var viewModel: ToDoListViewModel?
    
    /// 입력창 포커스 상태 (View 전용 UI 상태이므로 View에 유지)
    @FocusState private var isFocused: Bool

    // MARK: - Body
    var body: some View {
        NavigationSplitView {
            Group {
                if items.isEmpty {
                    // 리스트가 비어있을 때 표시할 뷰
                    VStack(spacing: 20) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        VStack(spacing: 8) {
                            Text("할 일이 없습니다")
                                .font(.headline)
                            Text("아래 입력창에서 첫 번째 할 일을 등록해보세요.\n최대 64개까지 알림과 함께 관리할 수 있습니다.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                    .onTapGesture {
                        hideKeyboard()
                    }
                } else {
                    // FIXME: 리스트 항목이 많아질 경우 성능 최적화 필요 (현재는 64개 제한으로 무관)
                    List {
                        ForEach(items) { item in
                            NavigationLink {
                                ToDoDetailView(item: item, modelContext: modelContext)
                            } label: {
                                ToDoRow(item: item)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            // 왼쪽에서 오른쪽으로 스와이프: 완료 토글
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel?.toggleCompletion(for: item)
                                } label: {
                                    Label(item.isCompleted ? "미완료" : "완료", systemImage: item.isCompleted ? "circle" : "checkmark.circle")
                                }
                                .tint(.green)
                            }
                            // 오른쪽에서 왼쪽으로 스와이프: 삭제
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel?.deleteItem(item)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete { offsets in
                            viewModel?.deleteItems(offsets: offsets, items: items)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("ToDo64")
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .fontWeight(.medium)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let viewModel = viewModel {
                    VStack {
                        HStack(alignment: .bottom, spacing: 16) {
                            // 제목 입력창
                            TextField("\(items.count + 1)번째 할 일 입력", text: Bindable(viewModel).newItemTitle)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(Color(.systemBackground))
                                .clipShape(Capsule())
                                .shadow(radius: 4)
                                .focused($isFocused)
                                .onSubmit {
                                    addItemWithFocusReset()
                                }
                                .onChange(of: viewModel.newItemTitle) { oldValue, newValue in
                                    if newValue.count > 40 {
                                        viewModel.newItemTitle = String(newValue.prefix(40))
                                    }
                                }
                            
                            // 오른쪽 버튼 (추가 버튼으로 고정)
                            Button(action: addItemWithFocusReset) {
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(viewModel.newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .disabled(viewModel.newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .alert("알림 한도 초과", isPresented: Bindable(viewModel).showLimitAlert) {
                                Button("확인", role: .cancel) { }
                            } message: {
                                Text("LocalNotification 제약으로 인해\n최대 64개까지만 추가할 수 있습니다.")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    }
                }
            }
        } detail: {
            Text("할 일을 선택해주세요")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ToDoListViewModel(modelContext: modelContext)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func addItemWithFocusReset() {
        viewModel?.addItem(currentCount: items.count)
        isFocused = false
    }
}

#Preview {
    ToDoListView()
        .modelContainer(for: ToDoItem.self, inMemory: true)
}
