let xarray = [];
let yarray = [];

let bullettime = []
let camtime = []

let akSpray;

let aktruex = [23, 22, 21, 19, 24, 33, 61,72,37, -15, -71, -90, -107, -127, -115, -60, -21, 12, 63, 85, 111, 102, 98, 98, 103, 105, 69, 19, -36, -68]
let aktruey = [-192, -170, -140, -103, -43, 0, 77, 111, 130, 131, 143, 146, 148, 145, 159, 177, 177, 185, 186, 184, 176, 184, 189, 194, 195, 200, 197, 193, 177, 163]

let bulletx = []
let bullety = []

let c
let ctx


function calculateDeviationPercentage(xArray, yArray, aktruex, aktruey) {
	if (xArray.length !== yArray.length || aktruex.length !== aktruey.length) {
	  throw new Error('Array lengths do not match.');
	}
  
	let deviationSum = 0;
	for (let i = 0; i < xArray.length; i++) {
	  const xDeviation = Math.abs(xArray[i] - aktruex[i]);
	  const yDeviation = Math.abs(yArray[i] - aktruey[i]);
	  const deviation = Math.sqrt(xDeviation ** 2 + yDeviation ** 2);
	  deviationSum += deviation;
	}
  
	const maximumDeviation = Math.sqrt(
	  (Math.max(...xArray) - Math.min(...xArray)) ** 2 +
	  (Math.max(...yArray) - Math.min(...yArray)) ** 2
	);
  
	if (maximumDeviation === 0) {
	  return 0; // No deviation when maximum deviation is zero
	}
	const averageDeviation = (deviationSum / (xArray.length * maximumDeviation)) * 100;  
	const clampedDeviation = Number(averageDeviation.toFixed(2)); // Clamping to two decimal places

	return clampedDeviation;
  }

function calcbulletcords(camtime,arrayx, arrayy,bullets)
{
	let bulletcounter = 0;
	for (let i = 0; i < arrayx.length; i++)
	{	
		if(bullets[bulletcounter] < camtime[i])
		{
			bulletcounter++;
			bulletx.push(-arrayx[i]);
			bullety.push(arrayy[i]);
		}
	}
	console.log(bulletx);
	console.log(bullety);

}
function connectWebSocket() {
	const socket = new WebSocket('ws://192.168.1.13:9091');
  
	socket.addEventListener('open', (event) => {
	  console.log('WebSocket connection opened');
	});
  
	socket.addEventListener('message', (event) => {

		let update = JSON.parse(event.data);
		
		switch (update["Type"])
		{
			case "VUP":
				var label1 = document.getElementById('rawValues');
				label1.innerText = "X: " + update['AY']  + " Y:" + update['AX'];
				break;
			case "update":
				console.log(update);
				bulletx = []
				bullety = []
				xarray = update["ShotXAngleCam"];
				yarray = update["ShotYAngleCam"];
				globalCoordinates = mapCoordinates(yarray,xarray,15);

				xarray = globalCoordinates.xArray;
				yarray = globalCoordinates.yArray;
				camtime = update["CamTimeStamp"]
				bullettime = update["BulletTimeStamp"];
				calcbulletcords(camtime,xarray,yarray,bullettime);
				let percentage = calculateDeviationPercentage(bulletx,bullety,aktruex,aktruey);
				console.log(percentage);
				var label2 = document.getElementById('percentage');
				label2.innerText = "Total Deviation " + percentage +"%";
				break;
		}
	});

	socket.addEventListener('close', (event) => {
	  console.log('WebSocket connection closed');
	  setTimeout(() => {
		console.log('Attempting to reconnect to WebSocket...');
		connectWebSocket();
	  }, 1000);
	});
  }


  function CanvasLoad()
  {
	c = document.getElementById("MiniMap");
	ctx = c.getContext("2d");

	ctx.translate(c.width / 2, c.height / 2);
	akSpray = new Image();
	akSpray.src = "assets\\maps\\weapon_ak47.png";
	
	akSpray.onload = function() {
		animate(); // Start the animation loop after the image is loaded
	  };
  }

  function animate() {
	
	ctx.save();
	ctx.setTransform(1, 0, 0, 1, 0, 0);
	ctx.clearRect(0, 0, c.width, c.height);
	ctx.restore();
	const imageX = -akSpray.width / 2;
  	const imageY = -akSpray.height / 2;
	ctx.drawImage(akSpray,imageX,imageY);

	let circleR = 3;

	var gradientColors = generateGradientColors(xarray.length);

	for (let i = 0; i < xarray.length; i++)
	{	
		ctx.beginPath();
		ctx.fillStyle = gradientColors[i];
		ctx.arc(-xarray[i],yarray[i],circleR,0,2*Math.PI);	
		ctx.fill();
	}


	for(let i = 0; i < bulletx.length; i++)
	{
		circleR = 4;
		ctx.beginPath();
		ctx.fillStyle = "green";
		ctx.arc(bulletx[i],bullety[i],circleR,0,2*Math.PI);
		ctx.fill();
	}

	requestAnimationFrame(animate);
}
  
function normalizeArray(array, inputMin, inputMax) {
    return array.map((value) => (value - inputMin) / (inputMax - inputMin));
}

function expandArray(array, outputMin, outputMax) {
    return array.map((value) => value * (outputMax - outputMin) + outputMin);
}


  function mapValue(value, inputMin, inputMax, outputMin, outputMax) {
	const normalizedValue = (value - inputMin) / (inputMax - inputMin);
	const mappedValue = normalizedValue * (outputMax - outputMin) + outputMin;
	return mappedValue;
  }

let yscale = .70;
let xscale = 1.50;

function mapCoordinates(pitchArray, yawArray, scaleFactor, startX, startY) {
    const xArray = pitchArray.map((pitch) => mapValue(pitch, -180, 180, -300, 300));
    const yArray = yawArray.map((yaw) => mapValue(yaw, -90, 90, -300, 300));
	
    // Calculate the center point
	const xStart = -23; // Example x starting point
	const yStart = -191; // Example y starting point
	
	// Calculate the center point
	const xCenter = xArray.reduce((a, b) => a + b) / xArray.length;
	const yCenter = yArray.reduce((a, b) => a + b) / yArray.length;
	
	// Calculate the offset based on the first value of the centered arrays
	const xOffset = xStart - ((xArray[0] - xCenter) * scaleFactor) * xscale;
	const yOffset = yStart - ((yArray[0] - yCenter) * scaleFactor) *yscale;
	
	// Adjust the coordinates based on the offset and apply scale factor
	const adjustedXArray = xArray.map((x) => (x - xCenter) * scaleFactor * xscale + xOffset);
	const adjustedYArray = yArray.map((y) => (y - yCenter) * scaleFactor *yscale + yOffset);

    return { xArray: adjustedXArray, yArray: adjustedYArray };
}
  
function generateGradientColors(steps) {
	var gradientColors = [];
	for (var i = 0; i <= steps; i++) {
	  // Calculate the ratio based on the index
	  var ratio = i / steps;
  
	  // Interpolate the RGB values based on the ratio
	  var r = Math.round((1 - ratio) * 255);
	  var b = Math.round(ratio * 255);
  
	  // Convert the RGB values to hexadecimal
	  var color = rgbToHex(r, 0, b);
	  gradientColors.push(color);
	}
  
	return gradientColors;
  }

  function rgbToHex(r, g, b) {
	var componentToHex = function (c) {
	  var hex = c.toString(16);
	  return hex.length == 1 ? '0' + hex : hex;
	};
	return '#' + componentToHex(r) + componentToHex(g) + componentToHex(b);
  }
  
connectWebSocket();