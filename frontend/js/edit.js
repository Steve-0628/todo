import { apiCall, renderNavbar } from './common.js';

const todoId = window.location.pathname.split('/').filter(Boolean).pop();

// DOM Elements
const titleInput = document.getElementById('title');
const contentInput = document.getElementById('content');
const isCompleteInput = document.getElementById('isComplete');
const expectedDueInput = document.getElementById('expectedDue');
const parentTodoSelect = document.getElementById('parentTodo');
const tagsSelect = document.getElementById('tags');
const statusMessage = document.getElementById('statusMessage');

async function loadTodoData() {
    try {
        const [todoRes, todosRes, tagsRes] = await Promise.all([
            apiCall(`/todos/${todoId}`),
            apiCall('/todos?page=0'),
            apiCall('/tags')
        ]);
        
        populateForm(todoRes.result, todosRes.result, tagsRes);
    } catch (error) {
        statusMessage.innerText = 'Failed to load data.';
    }
}

function populateForm(todo, allTodos, allTags) {
    titleInput.value = todo.title;
    contentInput.value = todo.content || '';
    isCompleteInput.checked = todo.isComplete;
    
    if (todo.expectedDue) {
        const date = new Date(todo.expectedDue);
        // Adjust for timezone offset for datetime-local
        const localIso = new Date(date.getTime() - (date.getTimezoneOffset() * 60000)).toISOString().slice(0, 16);
        expectedDueInput.value = localIso;
    }

    // Populate Parent Select
    parentTodoSelect.innerText = ''; 
    const defaultOption = document.createElement('option');
    defaultOption.value = '';
    defaultOption.innerText = 'None';
    parentTodoSelect.appendChild(defaultOption);
    
    allTodos.forEach(t => {
        if (t.id !== todo.id) {
            const option = document.createElement('option');
            option.value = t.id;
            option.innerText = t.title;
            if (todo.parentTodoId === t.id) {
                option.selected = true;
            }
            parentTodoSelect.appendChild(option);
        }
    });

    // Populate Tags Select
    tagsSelect.innerText = '';
    const currentTagIds = new Set(todo.tags.map(t => t.id));
    
    allTags.forEach(tag => {
        const option = document.createElement('option');
        option.value = tag.id;
        option.innerText = tag.name;
        if (currentTagIds.has(tag.id)) {
            option.selected = true;
        }
        tagsSelect.appendChild(option);
    });
}

async function handleSave() {
    if (!titleInput.value.trim()) {
        statusMessage.innerText = 'Title is required.';
        return;
    }
    const selectedOptions = Array.from(tagsSelect.selectedOptions);
    const selectedTags = selectedOptions.map(opt => ({
        id: parseInt(opt.value),
        name: opt.innerText
    }));

    const payload = {
        title: titleInput.value,
        content: contentInput.value,
        isComplete: isCompleteInput.checked,
        expectedDue: expectedDueInput.value ? new Date(expectedDueInput.value).getTime() : 0,
        parentTodoId: parentTodoSelect.value ? parseInt(parentTodoSelect.value) : null,
        tags: selectedTags
    };

    try {
        await apiCall(`/todos/${todoId}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        window.location.href = '/';
    } catch (error) {
        statusMessage.innerText = 'Failed to save.';
    }
}

async function handleDelete() {
    try {
        await apiCall(`/todos/${todoId}`, { method: 'DELETE' });
        window.location.href = '/';
    } catch (error) {
        statusMessage.innerText = 'Failed to delete.';
    }
}

// Initialization
renderNavbar();
loadTodoData();

document.getElementById('saveBtn').addEventListener('click', handleSave);

const deleteBtn = document.getElementById('deleteBtn');
const deleteConfirm = document.getElementById('deleteConfirm');
const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');

deleteBtn.addEventListener('click', () => {
    deleteBtn.style.display = 'none';
    deleteConfirm.style.display = 'block';
});

cancelDeleteBtn.addEventListener('click', () => {
    deleteConfirm.style.display = 'none';
    deleteBtn.style.display = 'inline-block';
});

confirmDeleteBtn.addEventListener('click', handleDelete);
