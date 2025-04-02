document.addEventListener("DOMContentLoaded", () => {
    paramKey = "document";
    window.scrollTo(0, 0);
    $("#document_url").on("change", function(e) {
      const value = e.target.value;
    });
    initBuildings();
    initPeople();
    function initPeople() {
      $("#person-question .btn-primary").on("click", function() {
        $("#person-question").fadeOut();
        $("#person-fields").fadeIn();
      });
      let autocompleteTimeout;
      $("#person-autocomplete").on("keyup", (e) => {
        if (e.keyCode === 13) {
          e.stopPropagation();
        }
        const input = e.target;
        const value = input.value;
        if (value.length > 1) {
          if (autocompleteTimeout) {
            window.clearTimeout(autocompleteTimeout);
          }
          autocompleteTimeout = window.setTimeout(() => {
            $.getJSON("/people/autocomplete", { term: value }, (json) => {
              const people = [];
              json.forEach((person) => {
                people.push(`<div class="list-group-item list-group-item-action" data-person=${person.id}>${person.name} (${person.id}) - ${person.years}</div>`);
              });
              $("#person-results").html(people).show();
              $("#person-results .list-group-item").on("click", (e2) => {
                const id = e2.target.dataset.person;
                const name = e2.target.innerHTML;
                addPerson(id, name);
                input.value = null;
                $("#person-results").html("");
              });
            });
          }, 500);
        }
      });
    }
    function initBuildings() {
      $("#building-question .btn-primary").on("click", function() {
        $("#building-question").fadeOut();
        $("#building-fields").fadeIn();
      });
      $("#building-autocomplete").on("keyup", (e) => {
        if (e.keyCode === 13) {
          e.stopPropagation();
        }
        const input = e.target;
        const value = input.value;
        if (value.length > 1) {
          $.getJSON("/buildings/autocomplete", { term: value }, (json) => {
            const buildings = [];
            json.forEach((building) => {
              buildings.push(`<div class="list-group-item list-group-item-action" data-building=${building.id} data-lat="${building.lat}" data-lon="${building.lon}">${building.address}</div>`);
            });
            $("#building-results").html(buildings).show();
            $("#building-results .list-group-item").on("click", (e2) => {
              const id = e2.target.dataset.building;
              const lat = e2.target.dataset.lat;
              const lon = e2.target.dataset.lon;
              const address = e2.target.innerHTML;
              addBuilding(id, address, lat, lon);
              input.value = null;
              $("#building-results").html("");
            });
          });
        }
      });
    }
    function addBuilding(id, address, lat, lon) {
      const formId = `documents_building_ids_${id}`;
      $(`#${formId}`).closest(".form-check").remove();
      const html = `<div class="form-check"><input type="checkbox" class="form-check-input" name="${paramKey}[building_ids][]" id="${formId}" value="${id}" checked /><label class="form-check-label" for="${formId}">${address}</label></div>`;
      $(`.${paramKey}_building_ids`).append(html);
      if ($(`.${paramKey}_building_ids input:checked`).length === 1) {
      }
    }
    function addPerson(id, name) {
      const formId = `${paramKey}_person_ids_${id}`;
      $(`#person-fields input[value=${id}]`).closest(".form-check").remove();
      const html = `<div class="form-check"><input type="checkbox" class="form-check-input" name="${paramKey}[person_ids][]" id="${formId}" value="${id}" checked /><label class="form-check-label" for="${formId}">${name}</label></div>`;
      $(`.${paramKey}_person_ids`).append(html);
    }
  });