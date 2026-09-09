// HUD MENU by Elixir FW

let preferenceid = 1;
let incar = false;

var hudSettings = [
  (health = {
    name: "health",
    show: true,
    value: 95,
  }),
  (armor = {
    name: "armor",
    show: true,
    value: 100,
  }),
  (food = {
    name: "food",
    show: true,
    value: 95,
  }),
  (water = {
    name: "water",
    show: true,
    value: 95,
  }),
  (drug = { name: "drug ", show: true, value: 100 }),
  (alcohol = { name: "alcohol ", show: true, value: 100 }),
  (oxygen = {
    name: "oxygen",
    show: true,
  }),
  (minimap = {
    name: "minimap",
    show: true,
  }),
  (harness = {
    name: "harness",
    show: true,
  }),
  (nitrous = {
    name: "nitrous",
    show: true,
  }),
  (speedometerFps = {
    name: "speedometerFps",
    value: 60,
  }),
  (stress = {
    name: "stress",
    show: true,
    value: 95,
  }),
  (stamina = {
    name: "stamina",
    show: true,
  }),
];

let isDynamicStressChecked = true;

function initDynamicStressSetting() {
  const stored = localStorage.getItem("isDynamicStressChecked");
  if (stored === null) {
    localStorage.setItem("isDynamicStressChecked", "true");
    isDynamicStressChecked = true;
    $(".dynamic_stress_input").prop("checked", false);
  } else {
    isDynamicStressChecked = stored === "true";
    $(".dynamic_stress_input").prop("checked", !isDynamicStressChecked);
  }
}

function applyDynamicStressVisibility(stressValue) {
  if (!isDynamicStressChecked) return;
  if (stressValue === 0 || stressValue === false) {
    $(".icon-cont[name=stress]").parent().parent().css("display", "none");
  }
}

$(document).ready(function () {
  $("._tab_1hwi9_98").click(function () {
    if ($(this).hasClass("_active_1hwi9_175")) {
      return;
    } else {
      $("._active_1hwi9_175").addClass("false");
      $(this).removeClass("false");
      $("._active_1hwi9_175").removeClass("_active_1hwi9_175");
      $(this).addClass("_active_1hwi9_175");

      $("._options_1hwi9_191").css("display", "none");
      $("._options_1hwi9_191[menuid=" + $(this).attr("menuid") + "]").css(
        "display",
        "flex"
      );
    }
  });

  $(".np-switch").on("input", function (e) {
    if ($(this).is(":checked")) {
      $(this).parent().children("label").addClass("enabled");
    } else {
      $(this).parent().children("label").removeClass("enabled");
    }
  });

  $(".settings-dropdown").click(function () {
    if ($(this).children(".options").css("display") == "none") {
      $(this).children(".options").css("display", "flex");
    } else {
      $(this).children(".options").css("display", "none");
    }
  });

  $(".option").click(function () {
    let Description = $(this).html();
    $(this)
      .parent()
      .parent()
      .children(".np-text-box")
      .prop("value", Description);
    if (
      $(this).parent().parent().children(".np-text-box").attr("trink") ==
      "preference"
    ) {
      loadPreference();
    }
  });

  $("._saveButton_1hwi9_61").click(function () {
    if ($("._options_1hwi9_191[menuid=hud]").css("display") == "flex") {
      saveSettings();
    } else if (
      $("._options_1hwi9_191[menuid=gameplay]").css("display") == "flex"
    ) {
      localStorage.setItem("hud_crosshair", $(".crosshairCb").is(":checked"));
      $.post(
        "https://qrt-hud/crosshair",
        JSON.stringify({
          active: $(".crosshairCb").is(":checked"),
        })
      );
    }
  });

  $(".black-bar-input").keyup(function (e) {
    var val = $(this).val();
    $(".black-bar").css("height", `${val}%`);
  });

  if ($(".black-bar-checkbox").is(":checked")) {
    $(".black-bar").css("display", "block");
  } else {
    $(".black-bar").css("display", "none");
  }

  $(".dynamic_stress_input").click(function () {
    isDynamicStressChecked = !$(this).is(":checked");
    localStorage.setItem(
      "isDynamicStressChecked",
      isDynamicStressChecked ? "true" : "false"
    );
    $.post(
      "https://qrt-hud/dynamicStress",
      JSON.stringify({ enabled: isDynamicStressChecked })
    );
  });

  $(".black-bar-checkbox").click(function () {
    if ($(this).is(":checked")) {
      $(".black-bar").css("display", "block");
      $.post(
        "https://qrt-hud/blackbar",
        JSON.stringify({
          show: true,
        })
      );
    } else {
      $(".black-bar").css("display", "none");
      $.post(
        "https://qrt-hud/blackbar",
        JSON.stringify({
          show: false,
        })
      );
    }
  });
});

function loadPreference() {
  if (localStorage.getItem("hud_crosshair")) {
    $(".crosshairCb").prop(
      "checked",
      JSON.parse(localStorage.getItem("hud_crosshair"))
    );
    $.post(
      "https://qrt-hud/crosshair",
      JSON.stringify({
        active: JSON.parse(localStorage.getItem("hud_crosshair")),
      })
    );
  } else {
    localStorage.setItem("hud_crosshair", $(".crosshairCb").is(":checked"));
    $.post(
      "https://qrt-hud/crosshair",
      JSON.stringify({
        active: $(".crosshairCb").is(":checked"),
      })
    );
  }


  initDynamicStressSetting();

  preferenceid = $(".np-text-box[trink=preference]").val();
  if (localStorage.getItem("hudSettings_" + preferenceid)) {
    hudSettings = JSON.parse(
      localStorage.getItem("hudSettings_" + preferenceid)
    );
    for (let i = 0; i < hudSettings.length; i++) {
      changeHudSettingInputs(hudSettings[i]);
    }
  } else {
    localStorage.setItem(
      "hudSettings_" + preferenceid,
      JSON.stringify(hudSettings)
    );
  }
}

function changeHudSettingInputs(data) {
  if (
    data.name == "health" ||
    data.name == "armor" ||
    data.name == "food" ||
    data.name == "water" ||
    data.name == "drug " ||
    data.name == "alcohol " || 
    data.name == "stress"
  ) {
    $("." + data.name + "_input").prop("checked", data.show);
    const thresholdInput =
      data.name === "stress"
        ? $(".stress-threshold-input")
        : $("." + data.name + "_input")
            .parent()
            .parent()
            .children(".settings-input-container")
            .children("input");
    thresholdInput.prop("value", data.value);
  } else if (
    data.name == "oxygen" ||
    data.name == "harness" ||
    data.name == "nitrous" ||
    data.name == "stamina"
  ) {
    $(".np-switch[name=" + data.name + "]").prop("checked", data.show);
  } else if (data.name == "speedometerFps") {
    $(".np-text-box[name=speedometerFps]").val(data.value);
    $.post(
      "https://qrt-hud/speedometerfps",
      JSON.stringify({
        fps: data.value,
      })
    );
  } else if (data.name == "minimap") {
    $(".np-switch[name=" + data.name + "]").prop("checked", data.show);
    $.post(
      "https://qrt-hud/minimapenabled",
      JSON.stringify({
        active: data.show,
      })
    );
  }

  refreshInputs();
}

function saveSettings() {
  $(".settings-switch-wrapper").each(function (e) {
    for (let i = 0; i < hudSettings.length; i++) {
      if (hudSettings[i].name == $(this).children("input").attr("name")) {
        hudSettings[i].show = $(this).children("input").is(":checked");
        let name = $(this).children("input").attr("name");
        if (
          name == "health" ||
          name == "armor" ||
          name == "food" ||
          name == "water" ||
          name == "drug " ||
          name == "alcohol "
        ) {
          hudSettings[i].value = $("." + name + "_input")
            .parent()
            .parent()
            .children(".settings-input-container")
            .children("input")
            .prop("value");
        } else if (name == "stress") {
          hudSettings[i].value = $(".stress-threshold-input").prop("value");
        }
      }
    }
  });
  for (let i = 0; i < hudSettings.length; i++) {
    if (hudSettings[i].name == "speedometerFps") {
      hudSettings[i].value = $(".np-text-box[name=speedometerFps]").val();
      $.post(
        "https://qrt-hud/speedometerfps",
        JSON.stringify({
          fps: hudSettings[i].value,
        })
      );
    } else if (hudSettings[i].name == "minimap") {
      $.post(
        "https://qrt-hud/minimapenabled",
        JSON.stringify({
          active: hudSettings[i].show,
        })
      );
    }
  }
  localStorage.setItem(
    "hudSettings_" + preferenceid,
    JSON.stringify(hudSettings)
  );
}

function refreshInputs() {
  $(".settings-switch-wrapper").each(function (e) {
    if ($(this).children("input").is(":checked")) {
      $(this).children("label").addClass("enabled");
    } else {
      $(this).children("label").removeClass("enabled");
    }
  });
}

// STATUS HUD

function updateBar(name, value) {
  $(".icon-cont[name=" + name + "")
    .children()
    .css("background-size", "100% " + value + "%");
  if (
    name == "database" ||
    name == "wind" ||
    name == "exclamation" ||
    name == "lightbulb" ||
    name == "dollar"
  ) {
    if (value <= 0) {
      $(".icon-cont[name=" + name + "")
        .parent()
        .parent()
        .css("display", "none");
    } else {
      $(".icon-cont[name=" + name + "")
        .parent()
        .parent()
        .css("display", "block");
    }
  } else {
    for (let i = 0; i < hudSettings.length; i++) {
      if (hudSettings[i].name == name) {
        if (
          (value >= hudSettings[i].value && hudSettings[i].value != 100) ||
          hudSettings[i].show == false ||
          value == false
        ) {
          $(".icon-cont[name=" + name + "")
            .parent()
            .parent()
            .css("display", "none");
        } else {
          $(".icon-cont[name=" + name + "")
            .parent()
            .parent()
            .css("display", "block");
        }
        if (name === "stress") {
          applyDynamicStressVisibility(value);
        }
        // ✅ Dynamic Visibility برای Armor, Drug, Alcohol
        // وقتی مقدار 0 هست، آیکن مخفی می‌شه
        if (name === "armor" || name === "drug" || name === "alcohol") {
            if (value === 0 || value === false || value === null || value === undefined) {
                $(".icon-cont[name=" + name + "]").parent().parent().css("display", "none");
            }
        }
      }
    }
  }
}

// CARHUD

function updateSpeed(veri) {
  if (veri.toString().length == 3) {
    var a = veri.toString().charAt(0);
    var b = veri.toString().charAt(1);
    var c = veri.toString().charAt(2);

    $(".speedometera:eq(0)").html(a);
    $(".speedometera:eq(1)").html(b);
    $(".speedometera:eq(2)").html(c);

    $(".speedometera:eq(0)").css("color", "white");
    $(".speedometera:eq(1)").css("color", "white");
    $(".speedometera:eq(2)").css("color", "white");
  } else if (veri.toString().length == 2) {
    var a = veri.toString().charAt(0);
    var b = veri.toString().charAt(1);

    $(".speedometera:eq(0)").html(0);
    $(".speedometera:eq(1)").html(a);
    $(".speedometera:eq(2)").html(b);

    $(".speedometera:eq(0)").css("color", "gray");
    $(".speedometera:eq(1)").css("color", "white");
    $(".speedometera:eq(2)").css("color", "white");
  } else if (veri.toString().length == 1) {
    var a = veri.toString().charAt(0);
    $(".speedometera:eq(0)").html(0);
    $(".speedometera:eq(1)").html(0);
    $(".speedometera:eq(2)").html(a);

    $(".speedometera:eq(0)").css("color", "gray");
    $(".speedometera:eq(1)").css("color", "gray");
    if (a != "0") {
      $(".speedometera:eq(2)").css("color", "white");
    } else {
      $(".speedometera:eq(2)").css("color", "gray");
    }
  }
}

function mapNumber(number, fromMin, fromMax, toMin, toMax) {
  return ((number - fromMin) * (toMax - toMin)) / (fromMax - fromMin) + toMin;
}

function rpmUpdate(rpm) {
  let mappedNumber = mapNumber(rpm * 10, 0, 10, 0, 17) + 1;
  $(".rpm-hud").each(function (index) {
    if (index < mappedNumber) {
      $(this)
        .addClass("ring-mediumspringgreen bg-mediumspringgreen")
        .removeClass("bg-neutral-600 ring-neutral-600");
      if (index <= 17 && index >= 15) {
        $(this).addClass("bg-red-500");
      }
    } else {
      $(this)
        .addClass("bg-neutral-600 ring-neutral-600")
        .removeClass("ring-mediumspringgreen bg-mediumspringgreen");
      if (index <= 17 && index >= 15) {
        $(this).removeClass("bg-red-500");
      }
    }
  });
}

function updateGear(gear) {
  if (gear == 0) {
    gear = "R";
  }
  $("#gearText").html(gear);
}

function updateFuel(a) {
  $("#fuelLevel1").css("height", a + "%");
}

function updatePursuit(a) {
  $("#pursuitMode").css("height", a + "%");
}




// INGAME  pursuitMode

window.addEventListener('message', function(event) {
  var fuelLevel1 = document.getElementById('fuelLevel1');
  var iconElement1 = document.getElementById('vehicleIcon1');
  var iconElement2 = document.getElementById('vehicleIcon2');

  var fuelLevel2 = document.getElementById('fuelLevel2');
  var iconElement3 = document.getElementById('vehicleIcon3');
  var iconElement4 = document.getElementById('vehicleIcon4');

  var pursuitMode = document.getElementById('PursuitMode');
  var pursuitModeIcon = document.getElementById('vehicleIcon5');

  var fuelLevel2Element = fuelLevel2.parentElement.parentElement;
  var pursuitModeElement = pursuitMode.parentElement.parentElement;

  if (event.data.action === 'enteredElectricVehicle') {
      fuelLevel1.style.backgroundColor = 'white'; // Charger
      iconElement1.style.display = "block";
      iconElement2.style.display = "none";

      fuelLevel2.style.backgroundColor = '#a95521'; // Battery
      fuelLevel2.style.height = event.data.vehicleIcon1Value + '%';
      iconElement3.style.display = "block";
      iconElement4.style.display = "none";
      fuelLevel2.parentElement.style.display = "flex"; // second bar and icons

      fuelLevel2Element.style.order = "1";
      pursuitModeElement.style.order = "2";   

  } if (event.data.action === 'enteredNonElectricVehicle') {
    fuelLevel1.style.backgroundColor = 'white';
    iconElement1.style.display = "none";
    iconElement2.style.display = "block";
  
    fuelLevel2.parentElement.style.display = "none"; // Hiding when car not electric
    iconElement3.style.display = "none"; 
    iconElement4.style.display = "none"; 

    fuelLevel2Element.style.order = "2";
    pursuitModeElement.style.order = "1";

} else if (event.data.action === 'PoliceVehicle') {
    pursuitMode.style.height = event.data.pursuit + '%';
    pursuitMode.style.backgroundColor = '#ef4444';
    pursuitMode.parentElement.style.display = "flex";
    pursuitMode.style.display = 'block'; 
    pursuitModeIcon.style.display = 'block';
} else if (event.data.action === 'NoPoliceVehicle') {
    pursuitMode.parentElement.style.display = "none";
    pursuitMode.style.display = 'none';
    pursuitModeIcon.style.display = 'none';
}
if (event.data.action === 'radioConnected' && event.data.wireless !== undefined) {
  document.getElementById("radio-icon").style.display = event.data.wireless ? "block" : "none";
  
  if (event.data.number !== undefined) {
    document.querySelector('.inter500.p-black62').textContent = event.data.number;
  
  }

  
}
  if (event.data.action === 'carHudUpdate') {
    pursuitMode.style.height = event.data.pursuit + '%';
  }

});

window.addEventListener("message", function (event) {

  if (event.data.action == "refreshStatus") {
    updateBar("health", event.data.health);
    updateBar("armor", event.data.armor);
    updateBar("food", event.data.food);
    updateBar("water", event.data.water);
    updateBar("oxygen", event.data.oxy);
    if (event.data.stress !== undefined) {
      updateBar("stress", event.data.stress);
      applyDynamicStressVisibility(event.data.stress);
    }
    if (event.data.stamina !== undefined) {
      updateBar("stamina", event.data.stamina);
    }
    if (event.data.drug !== undefined) {
        updateBar("drug", event.data.drug);
    }
    if (event.data.alcohol !== undefined) {
        updateBar("alcohol", event.data.alcohol);
    }
    if (incar) {
      updateBar("nitrous", event.data.nitrous);
      updateBar("harness", event.data.harness);
    } else {
      updateBar("nitrous", false);
      updateBar("harness", false);
    }
  } else if (event.data.action == "enchantmentNui") {
  
    updateBar(event.data.name, event.data.value);
  } else if (event.data.action == "openMenu") {
    $("._container_1hwi9_2").css("display", "block");
  } else if (event.data.action == "refreshPreference") {
    $(".np-text-box[trink=preference]").prop("value", event.data.preference);
    if (event.data.guides) {
      $("._options_1hwi9_191[menuid=help]").html("");
      for (let i = 0; i < event.data.guides.length; i++) {
        let html = `
                <div class="_option_1hwi9_191">
                    <div class="_texts_1hwi9_215">
                    <div class="_title_1hwi9_44">${event.data.guides[i].Title}</div>
                    <div class="_description_1hwi9_53">${event.data.guides[i].Description}</div>
                    </div>
                </div>
                `;
        $("._options_1hwi9_191[menuid=help]").append(html);
      }
    }
    loadPreference();
    } else if (event.data.action == "carHud") {
    if (event.data.open) {
      $("#carhud").css("display", "block");
      $("#pusula").css("display", "flex");
      incar = true;
    } else {
      $("#carhud").css("display", "none");
      $("#pusula").css("display", "none");
      incar = false;
    }
  } else if (event.data.action == "carHudUpdate") {
    updateSpeed(event.data.speed);
    rpmUpdate(event.data.rpm);
    updateGear(event.data.gear);
    updateFuel(event.data.fuel);
    updatePursuit(event.data.pursuit);

    if (event.data.altitude !== undefined) {
        updateAltitude(event.data.altitude);
    }
    if (event.data.cruise !== undefined) {
        updateCruise(event.data.cruise);
    }

    if (event.data.seatbelt) {
      $("#seatbelt").css("display", "none");
      $("#seatbelt").removeClass("pulsate");
    } else {
      $("#seatbelt").css("display", "block");
      $("#seatbelt").addClass("pulsate");
    }
  } else if (event.data.action == "updatePusula") {
    $("#streetName").html(
      event.data.locinfo.street1 + ", " + event.data.locinfo.street2
    );
    $("#zoneName").html(event.data.locinfo.zoneLabel);
    $("#pusulaimg").css(
      "background",
      "url(compas.png) " +
        event.data.locinfo.myHeading / 11 +
        "vh 0px / 100% repeat-x"
    );
    if (event.data.locinfo.waypointActive) {
      $("#waypointPusula").css("display", "block");
      let heading =
        event.data.locinfo.waypointHeading / 3 -
        event.data.locinfo.myHeading / 3;
      heading = heading * -1;
      if (heading >= 15) {
        heading = 15;
      } else if (heading <= -15) {
        heading = -15;
      }
      $("#waypointPusula").css("transform", "translateX(" + heading + "vh)");
    } else {
      $("#waypointPusula").css("display", "none");
    }
  } else if (event.data.action == "changeVoiceMode") {
    if (event.data.voiceMode == 0) {
      $(".icon-cont[name=voice]")
        .children()
        .css("background-size", "100% " + 45 + "%");
    } else if (event.data.voiceMode == 1) {
      $(".icon-cont[name=voice]")
        .children()
        .css("background-size", "100% " + 70 + "%");
    } else {
      $(".icon-cont[name=voice]")
        .children()
        .css("background-size", "100% " + 100 + "%");
    }
  } else if (event.data.action == "talking") {
    if (event.data.talking) {
      if (event.data.radioshit) {
        $(".icon-cont[name=radio]")
          .parent()
          .css("background", "rgba(185, 65, 65, 0.5)");
        $(".icon-cont[name=radio]").css(
          "background",
          "radial-gradient(rgba(185, 65, 65, 0.5), rgba(185, 65, 65, 0.5))"
        );
        $(".icon-cont[name=radio]")
          .children()
          .css(
            "background-image",
            " radial-gradient(rgba(185, 65, 65, 0.5), rgba(185, 65, 65, 0.5))"
          );
      } else {
        $(".icon-cont[name=voice]")
          .parent()
          .css("background", "rgba(255, 238, 0, 0.35)");
        $(".icon-cont[name=voice]").css(
          "background",
          "radial-gradient(rgba(255, 217, 0, 0), rgba(255, 251, 0, 0.5))"
        );
        $(".icon-cont[name=voice]")
          .children()
          .css(
            "background-image",
            " radial-gradient(rgba(255, 208, 0, 0.5), rgba(255, 238, 0, 0.5))"
          );
      }
    } else {
      $(".icon-cont[name=voice]")
        .parent()
        .css("background", "rgba(255, 255, 255, 0.35)");
      $(".icon-cont[name=voice]").css(
        "background",
        "radial-gradient(rgba(132, 132, 132, 0), rgba(255, 255, 255, 0.5))"
      );
      $(".icon-cont[name=voice]")
        .children()
        .css(
          "background-image",
          " radial-gradient(rgba(255, 255, 255, 0.5), rgba(255, 255, 255, 0.5))"
        );

        $(".icon-cont[name=radio]")
        .parent()
        .css("background", "rgba(255, 255, 255, 0.35)");
      $(".icon-cont[name=radio]").css(
        "background",
        "radial-gradient(rgba(132, 132, 132, 0), rgba(255, 255, 255, 0.5))"
      );
      $(".icon-cont[name=radio]")
        .children()
        .css(
          "background-image",
          " radial-gradient(rgba(255, 255, 255, 0.5), rgba(255, 255, 255, 0.5))"
        );
    }

    // RADIO NUMBER
    
    
  
  } else if (event.data.action == "parachute") {
    if (event.data.active) {
      $("#parachute").css("display", "block");
    } else {
      $("#parachute").css("display", "none");
    }
  } else if (event.data.action == "dev") {
    if (event.data.active) {
      $("#dev").css("display", "block");
    } else {
      $("#dev").css("display", "none");
    }
  } else if (event.data.action == "xHair") {
    if (event.data.active) {
      $(".crosshair").css("display", "block");
    } else {
      $(".crosshair").css("display", "none");
    }
  } else if (event.data.action == "debug") {
    if (event.data.active) {
      $("#debug").css("display", "block");
    } else {
      $("#debug").css("display", "none");
    }
  } else if (event.data.action == "god") {
    if (event.data.active) {
      $("#god").css("display", "block");
    } else {
      $("#god").css("display", "none");
    }
  } else if (event.data.action == "toggleHud") {
  if (event.data.show === false) {
    // مخفی کردن کامل HUD
    $("._container_1hwi9_2").css("display", "none");
    $("#carhud").css("display", "none");
    $("#pusula").css("display", "none");  // ✅ نقشه
    $(".crosshair").css("display", "none");
    $("#parachute").css("display", "none");
    $("#dev").css("display", "none");
    $("#debug").css("display", "none");
    $("#god").css("display", "none");
    $("#lowfuel").css("display", "none");
    $("#engine").css("display", "none");
    
    // مخفی کردن آیکون‌های status
    $('.icon-cont[name=radio]').parent().parent().css("display", "none");
    $('.icon-cont[name=drug]').parent().parent().css("display", "none");
    $('.icon-cont[name=alcohol]').parent().parent().css("display", "none");
  } else {
    // ✅ نمایش المان‌های اصلی HUD
    $(".icon-cont[name=health]").parent().parent().css("display", "block");
    $(".icon-cont[name=armor]").parent().parent().css("display", "block");
    $(".icon-cont[name=food]").parent().parent().css("display", "block");
    $(".icon-cont[name=water]").parent().parent().css("display", "block");
    
    // ✅ مخفی نگه داشتن نقشه تا زمانی که در ماشین نباشد
    $("#pusula").css("display", "none");
    $("#carhud").css("display", "none");
  }
}else if (event.data.action == "lowfuel") {
    if (event.data.active) {
      $("#lowfuel").css("display", "block");
    } else {
      $("#lowfuel").css("display", "none"); 
    }
  }  
  else if (event.data.action == "engine") {
    if (event.data.active) {
      $("#engine").css("display", "block");
    } else {
      $("#engine").css("display", "none");
    }
  }   

});

$(document).keyup(function (e) {
  if (e.key === "Escape") {
    $.post("https://qrt-hud/closeMenu");
    $("._container_1hwi9_2").css("display", "none");
  }
});


// MONEY HUD

if (typeof Vue === "undefined") {
  console.error("[qrt-hud] Vue is required for money HUD");
}

const moneyHud = typeof Vue !== "undefined" ? Vue.createApp({
  data() {
    return {
      cash: 0,
      bank: 0,
      amount: 0,
      plus: false,
      minus: false,
      showCash: false,
      showBank: false,
      showUpdate: false,
    };
  },
  destroyed() {
    window.removeEventListener("message", this.listener);
  },
  mounted() {
    this.listener = window.addEventListener("message", (event) => {
      switch (event.data.action) {
        case "showconstant":
          this.showConstant(event.data);
          break;
        case "updatemoney":
          this.update(event.data);
          break;
        case "show":
          this.showAccounts(event.data);
          break;
      }
    });
  },
  methods: {
    // CONFIGURE YOUR CURRENCY HERE
    // https://www.w3schools.com/tags/ref_language_codes.asp LANGUAGE CODES
    // https://www.w3schools.com/tags/ref_country_codes.asp COUNTRY CODES
    formatMoney(value) {
      const formatter = new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD",
        minimumFractionDigits: 0,
      });
      return formatter.format(value);
    },
    showConstant(data) {
      this.showCash = true;
      this.showBank = true;
      this.cash = data.cash;
      this.bank = data.bank;
    },
    update(data) {
      this.showUpdate = true;
      this.amount = data.amount;
      this.bank = data.bank;
      this.cash = data.cash;
      this.minus = data.minus;
      this.plus = data.plus;
      if (data.type === "cash") {
        if (data.minus) {
          this.showCash = true;
          this.minus = true;
          setTimeout(() => (this.showUpdate = false), 1000);
          setTimeout(() => (this.showCash = false), 2000);
        } else {
          this.showCash = true;
          this.plus = true;
          setTimeout(() => (this.showUpdate = false), 1000);
          setTimeout(() => (this.showCash = false), 2000);
        }
      }
      if (data.type === "bank") {
        if (data.minus) {
          this.showBank = true;
          this.minus = true;
          setTimeout(() => (this.showUpdate = false), 1000);
          setTimeout(() => (this.showBank = false), 2000);
        } else {
          this.showBank = true;
          this.plus = true;
          setTimeout(() => (this.showUpdate = false), 1000);
          setTimeout(() => (this.showBank = false), 2000);
        }
      }
    },
    showAccounts(data) {
      if (data.type === "cash" && !this.showCash) {
        this.showCash = true;
        this.cash = data.cash;
        setTimeout(() => (this.showCash = false), 3500);
      } else if (data.type === "bank" && !this.showBank) {
        this.showBank = true;
        this.bank = data.bank;
        setTimeout(() => (this.showBank = false), 3500);
      }
    },
  },
}) : null;

if (moneyHud && document.getElementById("money-container")) {
  moneyHud.mount("#money-container");
}


// =========================================================
// QRT ADDITIONS — On-Foot Compass + Door Lock (NoPixel Style)
// =========================================================
let qrtCompass = { circle: false, bar: false };

$(function () {
  // ----- آیکن قفل درها کنار کمربند -----
  if ($("#seatbelt").length && !$("#doorlock").length) {
    $("#seatbelt").parent().append(
      '<div id="doorlock">' +
        '<svg id="doorlock-open" viewBox="0 0 24 24"><path d="M12 17c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm6-9h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6h1.9c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2z"/></svg>' +
        '<svg id="doorlock-closed" viewBox="0 0 24 24"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zM9 8V6c0-1.66 1.34-3 3-3s3 1.34 3 3v2H9z"/></svg>' +
      "</div>"
    );
  }

  // ----- قطب‌نما پیاده (دایره + نوار) -----
  if (!$("#foot-compass").length) {
    $("body").append(
      '<div id="foot-compass">' +
        '<div id="fc-bar">' +
          '<div id="fc-img"></div>' +
          '<div id="fc-streets"><span id="fc-street"></span><span id="fc-zone"></span></div>' +
        "</div>" +
        '<div id="fc-circle">' +
          '<div id="fc-ring">' +
            '<span class="fc-card fc-n">N</span>' +
            '<span class="fc-card fc-e">E</span>' +
            '<span class="fc-card fc-s">S</span>' +
            '<span class="fc-card fc-w">W</span>' +
          "</div>" +
          '<div id="fc-needle"></div>' +
          '<div id="fc-heading">000°</div>' +
        "</div>" +
      "</div>"
    );
  }
});

window.addEventListener("message", function (event) {
  const d = event.data;

  // ----- آیا آیتم قطب‌نما رو داره؟ -----
  if (d.action === "compassConfig") {
    qrtCompass.circle = !!d.circle;
    qrtCompass.bar = !!d.bar;
    if (!qrtCompass.circle && !qrtCompass.bar) {
      $("#foot-compass").css("display", "none");
    }
    return;
  }

  // ----- قطب‌نما پیاده -----
  if (d.action === "updatePusula" && d.onFoot !== undefined) {
    if (d.onFoot) {
      const li = d.locinfo;
      const heading = Math.round(li.myHeading) % 360;
      if (d.compassStyle === "circle" && qrtCompass.circle) {
        $("#foot-compass").css("display", "block");
        $("#fc-circle").css("display", "block");
        $("#fc-bar").css("display", "none");
        $("#fc-ring").css("transform", "rotate(" + -heading + "deg)");
        $("#fc-heading").text(("00" + heading).slice(-3) + "°");
      } else if (qrtCompass.bar) {
        $("#foot-compass").css("display", "block");
        $("#fc-bar").css("display", "flex");
        $("#fc-circle").css("display", "none");
        $("#fc-street").text(li.street1 + (li.street2 ? ", " + li.street2 : ""));
        $("#fc-zone").text(li.zoneLabel);
        $("#fc-img").css(
          "background",
          "url(compas.png) " + li.myHeading / 11 + "vh 0px / 100% repeat-x"
        );
      } else {
        $("#foot-compass").css("display", "none");
      }
    } else {
      $("#foot-compass").css("display", "none");
    }
    return;
  }

  // ----- آیکن قفل درها -----
  if (d.action === "carHudUpdate" && d.doorsLocked !== undefined) {
    $("#doorlock").css("display", "flex");
    if (d.doorsLocked) {
      $("#doorlock").addClass("locked");
      $("#doorlock-closed").css("display", "block");
      $("#doorlock-open").css("display", "none");
    } else {
      $("#doorlock").removeClass("locked");
      $("#doorlock-closed").css("display", "none");
      $("#doorlock-open").css("display", "block");
    }
  }
});

// ✅ آپدیت ارتفاع - هماهنگ با استایل CarHUD
function updateAltitude(val) {
    const display = $("#altitude-display");
    const value = $("#altitude-value");
    
    if (val > 0) {
        display.css("display", "flex");
        value.text(val + "m");
        
        // تغییر رنگ در ارتفاعات بالا
        if (val > 300) {
            value.css("color", "#ef4444");
            display.find("svg").css("stroke", "#ef4444");
        } else if (val > 150) {
            value.css("color", "#f59e0b");
            display.find("svg").css("stroke", "#f59e0b");
        } else {
            value.css("color", "#ffffff");
            display.find("svg").css("stroke", "#ffffff");
        }
    } else {
        display.css("display", "none");
    }
}

// ✅ آپدیت کروز کنترل - هماهنگ با استایل CarHUD
function updateCruise(active) {
    const display = $("#cruise-display");
    
    if (active) {
        display.css("display", "flex");
    } else {
        display.css("display", "none");
    }
}
