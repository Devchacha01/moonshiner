const RESOURCE_NAME = GetParentResourceName();
let currentMenuOptions = [];
let selectedIndex = 0;
let isMenuOpen = false;
let progressInterval = null;

// Mini-Game Variables (Mash Fill)
let gameInterval = null;
let isGameRunning = false;
let fillLevel = 0; // 0 to 100%
let isSpaceHeld = false;
let isFilling = false;
let hasStartedPouring = false;


$(document).ready(function () {
    window.addEventListener('message', function (event) {
        let data = event.data;
        if (data.action === "openMenu") {
            openMenu(data.title, data.options);
        } else if (data.action === "closeMenu") {
            closeMenu();
        } else if (data.action === "startProgress") {
            startProgress(data.label, data.duration);
        } else if (data.action === "stopProgress") {
            stopProgress();
        } else if (data.action === "startMiniGame") {
            startMiniGame(data.difficulty || 'easy');
        } else if (data.action === "spaceDown") {
            if (isGameRunning) {
                isSpaceHeld = true;
                if (!hasStartedPouring) hasStartedPouring = true;
            }
        } else if (data.action === "spaceUp") {
            if (isGameRunning) {
                isSpaceHeld = false;
                // If they released space after starting, that's their "stop"
                if (hasStartedPouring) {
                    checkResult();
                }
            }
        } else if (data.action === "cancelGame") {
            if (isGameRunning) {
                endMiniGame('cancel');
            }
        }
    });

    document.addEventListener('keydown', function (event) {
        if (isMenuOpen) {
            if (event.which == 38) { // Up
                selectedIndex--;
                if (selectedIndex < 0) selectedIndex = currentMenuOptions.length - 1;
                updateSelection();
            } else if (event.which == 40) { // Down
                selectedIndex++;
                if (selectedIndex >= currentMenuOptions.length) selectedIndex = 0;
                updateSelection();
            } else if (event.which == 13) { // Enter
                selectOption();
            } else if (event.which == 8) { // Backspace
                closeMenu();
                $.post('https://rsg-moonshiner/closeMenu', JSON.stringify({}));
            }
        }
    });
});

/* Menu Functions */
function openMenu(title, options) {
    $("#menu-title").text(title);
    $("#menu-options-list").empty();
    currentMenuOptions = options;
    selectedIndex = 0;

    options.forEach((opt, index) => {
        let el = $(`
            <div class="menu-option" id="opt-${index}">
                <div class="title">${opt.title}</div>
                <div class="description">${opt.description || ''}</div>
            </div>
        `);

        el.click(function () {
            selectedIndex = index;
            updateSelection();
            selectOption();
        });

        $("#menu-options-list").append(el);
    });

    updateSelection();
    $("#menu-interface").removeClass("hidden");
    isMenuOpen = true;
}

function updateSelection() {
    $(".menu-option").removeClass("selected");
    $(`#opt-${selectedIndex}`).addClass("selected");

    let el = document.getElementById(`opt-${selectedIndex}`);
    if (el) el.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
}

function selectOption() {
    let opt = currentMenuOptions[selectedIndex];
    if (opt) {
        $.post('https://rsg-moonshiner/selectOption', JSON.stringify({
            index: selectedIndex + 1,
            data: opt
        }));
    }
}

function closeMenu() {
    $("#menu-interface").addClass("hidden");
    isMenuOpen = false;
}

/* Progress Functions */
function startProgress(label, duration) {
    $("#progress-label").text(label);
    $("#progress-fill").css("width", "0%");
    $("#progress-text").text("0%");

    $("#progress-interface").removeClass("hidden");

    let startTime = Date.now();

    if (progressInterval) clearInterval(progressInterval);

    progressInterval = setInterval(() => {
        let now = Date.now();
        let pct = ((now - startTime) / duration) * 100;

        if (pct >= 100) {
            pct = 100;
            clearInterval(progressInterval);
            $.post('https://rsg-moonshiner/progressComplete', JSON.stringify({}));
        }

        $("#progress-fill").css("width", pct + "%");
        $("#progress-text").text(Math.floor(pct) + "%");
    }, 50);
}
/* Mini-Game Functions */
function startMiniGame(difficulty) {
    // Show Interface
    $("#minigame-interface").removeClass("hidden");
    isGameRunning = true;

    // Reset State
    fillLevel = 0;
    isSpaceHeld = false;
    hasStartedPouring = false;
    isFilling = true;

    // Reset Visuals
    $("#mash-fill").css("height", "0%");
    $("#status-msg").text("Hold SPACE to Fill Mash");
    $("#status-msg").css("color", "#eecfa1");

    // Game Loop
    if (gameInterval) clearInterval(gameInterval);

    gameInterval = setInterval(() => {
        if (!isFilling) return;

        if (isSpaceHeld) {
            // Fill up - speed can depend on difficulty if desired
            fillLevel += 0.8;
        }

        // Update Visuals
        if (fillLevel > 100) fillLevel = 100;
        $("#mash-fill").css("height", fillLevel + "%");

        // Auto-fail if overfilled
        if (fillLevel >= 100) {
            checkResult();
        }

    }, 30); // 30ms tick for smooth animation
}

function checkResult() {
    isFilling = false;
    if (gameInterval) clearInterval(gameInterval);

    // Target Zone: 70% to 85%
    let targetStart = 70;
    let targetEnd = 85;

    let result = 'fail';

    if (fillLevel >= targetStart && fillLevel <= targetEnd) {
        // Perfect zone: 76% to 79% (middle of 70-85 approx)
        if (fillLevel >= 76 && fillLevel <= 79) {
            result = 'perfect';
            $("#status-msg").text("PERFECT FERMENTATION!");
            $("#status-msg").css("color", "gold");
        } else {
            result = 'success';
            $("#status-msg").text("Good Level!");
            $("#status-msg").css("color", "#4caf50");
        }
    } else if (fillLevel < targetStart) {
        $("#status-msg").text("Underfilled!");
        $("#status-msg").css("color", "#d32f2f");
    } else {
        $("#status-msg").text("Overflowed!");
        $("#status-msg").css("color", "#d32f2f");
    }

    // Delay slightly to show result
    setTimeout(() => {
        endMiniGame(result);
    }, 1500); // 1.5s delay to see result
}

function endMiniGame(result) {
    if (gameInterval) clearInterval(gameInterval);
    isGameRunning = false;
    isSpaceHeld = false;

    $("#minigame-interface").addClass("hidden");

    $.post('https://rsg-moonshiner/miniGameResult', JSON.stringify({
        success: result // 'success', 'fail', 'perfect', 'cancel'
    }));
}
function stopProgress() {
    if (progressInterval) clearInterval(progressInterval);
    $("#progress-interface").addClass("hidden");
}


