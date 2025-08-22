import { Application } from "@hotwired/stimulus"

document.addEventListener('DOMContentLoaded', function() {
  initializeFolderFunctionality();
});

function initializeFolderFunctionality() {
  // Inicializar filtros de perfiles
  initializeProfileFilters();
  
  // Inicializar menús de acciones
  initializeActionMenus();
  
  // Inicializar modal
  initializeCreateModal();
  
  // Cerrar menús al hacer clic fuera
  setupClickOutsideHandlers();
}

function initializeProfileFilters() {
  const filterChips = document.querySelectorAll('.filter-chip');
  const folders = document.querySelectorAll('.folder-card');
  
  if (filterChips.length === 0) return;
  
  filterChips.forEach(chip => {
    chip.addEventListener('click', () => {
      const profileId = chip.dataset.profile;
      
      // Remover clase activa de todos los chips
      filterChips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      
      // Filtrar carpetas
      if (profileId === 'all') {
        folders.forEach(folder => {
          folder.style.display = 'block';
          folder.style.opacity = '1';
        });
      } else {
        folders.forEach(folder => {
          const folderProfiles = folder.dataset.profiles.split(',');
          if (folderProfiles.includes(profileId)) {
            folder.style.display = 'block';
            folder.style.opacity = '1';
          } else {
            folder.style.display = 'none';
            folder.style.opacity = '0';
          }
        });
      }
    });
  });
}

function initializeActionMenus() {
  const actionButtons = document.querySelectorAll('.btn-actions');
  
  actionButtons.forEach(button => {
    button.addEventListener('click', (e) => {
      e.stopPropagation();
      toggleActionMenu(button);
    });
  });
}

function toggleActionMenu(button) {
  const menu = button.nextElementSibling;
  const allMenus = document.querySelectorAll('.actions-menu');
  
  // Cerrar todos los otros menús
  allMenus.forEach(m => {
    if (m !== menu) {
      m.classList.remove('show');
    }
  });
  
  // Toggle del menú actual
  menu.classList.toggle('show');
}

function initializeCreateModal() {
  const modal = document.getElementById('createFolderModal');
  if (!modal) return;
  
  // Configurar checkboxes de perfiles
  const profileCheckboxes = document.querySelectorAll('.profile-checkbox');
  profileCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      const profileOption = this.closest('.profile-option');
      if (this.checked) {
        profileOption.style.borderColor = '#3b82f6';
        profileOption.style.background = '#eff6ff';
      } else {
        profileOption.style.borderColor = '#e2e8f0';
        profileOption.style.background = '#f8fafc';
      }
    });
  });
  
  // Configurar botón de toggle de filtros
  const toggleFiltersBtn = document.querySelector('.btn-toggle-filters');
  if (toggleFiltersBtn) {
    toggleFiltersBtn.addEventListener('click', toggleProfileFilters);
  }
}

function toggleProfileFilters() {
  const filters = document.getElementById('profileFilters');
  const toggleBtn = document.querySelector('.btn-toggle-filters i');
  
  if (filters.style.display === 'none' || filters.style.display === '') {
    filters.style.display = 'block';
    toggleBtn.className = 'fas fa-chevron-up';
  } else {
    filters.style.display = 'none';
    toggleBtn.className = 'fas fa-chevron-down';
  }
}

function setupClickOutsideHandlers() {
  // Cerrar menús de acciones al hacer clic fuera
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.action-dropdown')) {
      document.querySelectorAll('.actions-menu').forEach(menu => {
        menu.classList.remove('show');
      });
    }
  });
  
  // Cerrar filtros de perfiles al hacer clic fuera
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.profile-filter-section')) {
      const filters = document.getElementById('profileFilters');
      const toggleBtn = document.querySelector('.btn-toggle-filters i');
      if (filters && toggleBtn) {
        filters.style.display = 'none';
        toggleBtn.className = 'fas fa-chevron-down';
      }
    }
  });
}

// Función global para usar en onclick del HTML
window.toggleActionsMenu = toggleActionMenu;
window.toggleProfileFilters = toggleProfileFilters;
