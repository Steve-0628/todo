import { apiCall, renderNavbar, formatDate } from './common.js';

const todoList = document.getElementById('todoList');
const sortBySelect = document.getElementById('sortBy');
const sortDirectionSelect = document.getElementById('sortDirection');
const completionFilterSelect = document.getElementById('completionFilter');
const searchInput = document.getElementById('searchInput');
const searchBtn = document.getElementById('searchBtn');

async function fetchAndRenderTodos() {
    const params = new URLSearchParams();
    params.append('page', 0); // Pagination could be handled better, but keeping simple for now
    params.append('orderBy', sortBySelect.value);
    params.append('desc', sortDirectionSelect.value === 'desc' ? 'true' : 'false');
    
    if (completionFilterSelect.value === 'completed') {
        params.append('isComplete', 'true');
    } else if (completionFilterSelect.value === 'not_completed') {
        params.append('isComplete', 'false');
    }

    const searchQuery = searchInput.value;
    if (searchQuery) {
        params.append('search', searchQuery);
    }

    try {
        const data = await apiCall(`/todos?${params.toString()}`);
        renderTodoList(data.result);
    } catch (error) {
        todoList.innerText = '';
        const div = document.createElement('div');
        div.innerText = 'Failed to load todos.';
        todoList.appendChild(div);
    }
}

function renderTodoList(todos) {
    todoList.innerText = '';

    if (!todos || todos.length === 0) {
        const div = document.createElement('div');
        div.innerText = 'No todos found using current filter.';
        todoList.appendChild(div);
        return;
    }

    todos.forEach(todo => {
        const item = document.createElement('div');
        item.className = 'todo-item';
        
        // Link wrapper
        const link = document.createElement('a');
        link.href = `/detail/${todo.id}`;
        link.className = 'todo-link';

        const titleDiv = document.createElement('div');
        titleDiv.className = 'todo-link';
        titleDiv.innerText = todo.title;
        link.appendChild(titleDiv);
        item.appendChild(link);

        // Dates
        const createdDiv = document.createElement('div');
        createdDiv.innerText = `Created: ${formatDate(todo.createdAt)} | Updated: ${formatDate(todo.updatedAt)}`;
        item.appendChild(createdDiv);

        const dueDiv = document.createElement('div');
        dueDiv.innerText = `Due: ${formatDate(todo.expectedDue)}`;
        item.appendChild(dueDiv);

        // Tags
        if (todo.tags && todo.tags.length > 0) {
            const tagsSpan = document.createElement('span');
            todo.tags.forEach(tag => {
                const tagSpan = document.createElement('span');
                tagSpan.className = 'tag';
                tagSpan.innerText = tag.name;
                tagsSpan.appendChild(tagSpan);
            });
            item.appendChild(tagsSpan);
        }

        todoList.appendChild(item);
    });
}

// Event Listeners
sortBySelect.addEventListener('change', fetchAndRenderTodos);
sortDirectionSelect.addEventListener('change', fetchAndRenderTodos);
completionFilterSelect.addEventListener('change', fetchAndRenderTodos);
searchBtn.addEventListener('click', fetchAndRenderTodos);
// Optional: Search on enter
searchInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') fetchAndRenderTodos();
});

// Initialization
renderNavbar();
fetchAndRenderTodos();
