import { apiCall, renderNavbar } from './common.js';

const parentSelect = document.getElementById('parentTodo');
const tagsSelect = document.getElementById('tags');
const statusMessage = document.getElementById('statusMessage');

// Inputs
const titleInput = document.getElementById('title');
const contentInput = document.getElementById('content');
const expectedDueInput = document.getElementById('expectedDue');

async function loadOptions() {
    try {
        const [todosRes, tagsRes] = await Promise.all([
            apiCall('/todos?page=0'),
            apiCall('/tags')
        ]);
        
        renderOptions(todosRes.result, tagsRes);
    } catch (error) {
        statusMessage.innerText = 'Failed to load options.';
    }
}

function renderOptions(allTodos, allTags) {
    // Parent Todo Select
    parentSelect.innerText = '';
    const defaultOption = document.createElement('option');
    defaultOption.value = '';
    defaultOption.innerText = 'None';
    parentSelect.appendChild(defaultOption);
    
    allTodos.forEach(t => {
        const option = document.createElement('option');
        option.value = t.id;
        option.innerText = t.title;
        parentSelect.appendChild(option);
    });

    // Tags Select
    tagsSelect.innerText = '';
    allTags.forEach(tag => {
        const option = document.createElement('option');
        option.value = tag.id;
        option.innerText = tag.name;
        tagsSelect.appendChild(option);
    });
}

async function handleCreate() {
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
        // Default time if not present, otherwise convert date string to millis
        expectedDue: expectedDueInput.value ? new Date(expectedDueInput.value).getTime() : 0,
        parentTodoId: parentSelect.value ? parseInt(parentSelect.value) : null,
        tags: selectedTags
    };

    try {
        await apiCall('/todos', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        window.location.href = '/';
    } catch (error) {
        statusMessage.innerText = 'Failed to create todo.';
    }
}

// Initialization
renderNavbar();
loadOptions();

document.getElementById('createBtn').addEventListener('click', handleCreate);
