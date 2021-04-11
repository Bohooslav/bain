export tag downloads-page
	def setup
		window.showimage = no

	def mount
		window.scroll(0, 0)
		$video.autoplay = yes
		$video.loop = yes
		document.title = "Bolls · " + data.lang.download

	def install
		data.deferredPrompt.prompt()


	def showImage e
		window.showimage = yes
		imba.commit!

	def render
		<self[d: block h: 100vh ofy: auto]>
			<a[display: flex; c:inherit @hover:$accent-color fill:$text-color @hover:$accent-color] route-to='/'>
				<svg.svgBack [pos:relative m:auto 16px auto 0 l:8px fill:inherit] xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
					<title> data.lang.back
					<path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
				<span[margin: 24px font-weight: 500]> data.lang.back
			<header[text-align: center]>
				<img[height: 128px width: 128px] src="/static/logoshield.png" alt="Bolls logo">
				<h1.exhortation> data.lang.exhortation
				unless hideInstallPromotion
					<div#pwa>
						if data.addBtn
							<button.platform-item @click.prevent.install() [display: inline-flex width: auto animation: text-came 300ms ease]>
								<img.platforms_svg src="/static/android-chrome-512x512.png" alt="Bolls logo">
								<p> data.lang.install_app
						else
							<p[font-family: monospace font-size: 12px]> data.lang.ugch
			<#downloads-container>
				<a.platform-item rel="noreferrer" target="_blank" href="http://bolls.life">
					<svg.platforms_svg xmlns="http://www.w3.org/2000/svg" role="img"  viewBox="0 0 28 28">
						<title> data.lang.use_it_in_browser
						<path d="M13.953 0A13.9 13.9 0 0 1 21 1.875a14.04 14.04 0 0 1 5.5 5.812l-11.594-.609c-3.281-.187-6.406 1.656-7.484 4.75L3.11 5.203C5.798 1.859 9.829.016 13.954 0zM2.281 6.328l5.266 10.359c1.484 2.922 4.625 4.703 7.875 4.094l-3.594 7.047C5.125 26.797 0 21 0 14c0-2.828.844-5.469 2.281-7.672zm24.781 2.641c2.453 6.312 0 13.656-6.062 17.156a13.962 13.962 0 0 1-7.781 1.859l6.328-9.734c1.797-2.766 1.766-6.375-.375-8.875zM14 9.281c2.609 0 4.719 2.109 4.719 4.719S16.61 18.719 14 18.719 9.281 16.61 9.281 14 11.39 9.281 14 9.281z">
					<p> data.lang.use_it_in_browser
				<a.platform-item rel="noreferrer" target="_blank" href="https://play.google.com/store/apps/details?id=life.bolls.bolls">
					<svg.platforms_svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 505.499 505.499" style="enable-background:new 0 0 505.499 505.499;" xml:space="preserve">
						<title> data.lang.snapstore, " Google Play"
						<g>
							<path d="M471.497,234.466l-92.082-53.135l-75.733,73.207l69.215,66.907l98.599-56.91c5.432-3.133,8.678-8.756,8.678-15.03 C480.175,243.23,476.929,237.607,471.497,234.466z">
							<polygon points="363.785,172.301 262.453,113.803 40.375,0 291.203,242.471">
							<polygon points="44.063,505.499 262.834,384.988 357.268,330.473 291.203,266.604">
							<polygon points="25.559,9.815 25.324,499.486 278.721,254.533">
					<p> data.lang.snapstore, <br>, " Google Play"
				<a.platform-item rel="noreferrer" target="_blank" href="https://appgallery7.huawei.com/#/app/C102565527">
					<svg.platforms_svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 1000 1000" enable-background="new 0 0 1000 1000" xml:space="preserve">
						<title> data.lang.snapstore, " AppGallery"
						<g>
							<path d="M428.9,125.9c0,0-78.2-3.7-128.1,63.6c-49.9,67.4-12.4,170.3,11.2,223.3c23.7,53.1,148.5,261.3,153.1,265.9c4.6,4.6,10,2.7,10.3-1.5c0.3-4.1,14.3-302.6,3-376.2C467.2,227.5,434,134,428.9,125.9z">
							<path d="M158.5,264.7c-8.9,1-73.1,67.9-78.9,133.2c-5.8,65.4,21,108.9,95.7,160.9c75.3,55.8,254.2,158.4,257.5,149.5c3.3-8.8-69.3-143.6-128.7-241.6C244.6,368.7,167.4,263.7,158.5,264.7z">
							<path d="M182.6,867.7c54.1,25.3,138.5-31.5,161.8-48c21.7-17.3,61.8-49.2,61.8-49.2l-306.8,8.6C99.4,779.1,128.4,842.4,182.6,867.7z">
							<path d="M190.3,608.7C135.4,580,22.4,514,18,515.3c-4.4,1.3-21.4,83.3,13.9,145.2c35.3,61.8,104.1,80.8,135.7,85.8c35.5,5.3,244.2,2.9,242.8-1.5C409.1,741,245.2,637.4,190.3,608.7z">
							<path d="M699.2,189.6c-49.9-67.4-128.1-63.6-128.1-63.6c-5.1,8.1-38.4,101.6-49.6,175.2c-11.2,73.6,2.8,372.1,3.1,376.2c0.3,4.1,5.7,6.1,10.3,1.5c4.6-4.6,129.4-212.9,153.1-265.9C711.7,359.8,749.1,256.9,699.2,189.6z">
							<path d="M982,515.3c-4.4-1.3-117.4,64.7-172.3,93.4C754.8,637.4,590.9,741,589.7,744.8c-1.4,4.4,207.3,6.7,242.8,1.5c31.6-5.1,100.4-24,135.7-85.8C1003.5,598.6,986.4,516.6,982,515.3z">
							<path d="M655.6,819.7c23.3,16.5,107.7,73.3,161.8,48c54.1-25.3,83.2-88.6,83.2-88.6l-306.8-8.6C593.9,770.5,634,802.4,655.6,819.7z">
							<path d="M920.4,398c-5.8-65.4-70-132.2-78.9-133.2c-8.9-1-86.2,104-145.6,202c-59.4,98-132,232.8-128.7,241.6c3.3,8.8,182.2-93.8,257.5-149.5C899.4,506.8,926.2,463.3,920.4,398z">
					<p> data.lang.snapstore, <br>, " AppGallery"
				<a.platform-item rel="noreferrer" target="_blank" href="https://www.microsoft.com/store/productId/9PFBQBR77J81">
					<svg.platforms_svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 1000 1000" enable-background="new 0 0 1000 1000" xml:space="preserve">
						<title> data.lang.snapstore, " Windows Store"
						<g transform="translate(0.000000,250.000000) scale(0.100000,-0.100000)">
							<path d="M3701.9,2338.6c-362.4-130-697.3-437.3-886.4-823.4l-130-263.9l-11.8-740.6c-11.8-697.3-7.9-740.6,59.1-740.6c153.6,0,161.5,43.3,177.3,748.5c11.8,642.1,19.7,701.2,110.3,886.4c55.2,110.3,181.2,279.7,283.7,386.1c579.1,583.1,1414.3,445.2,1761-287.6c90.6-189.1,102.4-275.8,114.2-717l15.8-504.3h98.5h98.5l-15.8,583.1c-11.8,524-23.6,598.8-114.2,799.7c-122.1,256.1-374.3,512.1-622.5,634.3C4395.3,2417.4,3969.8,2433.1,3701.9,2338.6z">
							<path d="M5384.1,1700.4c0-63,114.3-149.7,256.1-189.1c200.9-55.2,425.5-240.3,508.2-417.6c35.4-78.8,63-232.4,63-378.2c0-228.5,3.9-240.3,90.6-228.5c82.8,11.8,86.7,27.6,74.9,327c-7.9,224.6-35.5,346.7-90.6,437.3c-86.7,141.8-291.5,307.3-457,374.3C5687.5,1684.6,5384.1,1735.8,5384.1,1700.4z">
							<path d="M4659.2,1499.4c-370.3-248.2-492.4-504.3-496.4-1047.9c0-366.4,0-366.4,98.5-366.4s98.5,3.9,98.5,366.4c0,264,19.7,405.8,74.8,520c74.8,169.4,334.9,429.4,472.7,472.7c67,19.7,74.8,39.4,43.3,102.4C4895.6,1645.2,4879.8,1641.3,4659.2,1499.4z">
							<path d="M6920.5,258.5C6132.6,97,4415-245.8,2193.1-687c-508.2-102.4-1024.3-204.8-1142.5-228.5l-216.7-47.3v-2537.1V-6033l728.8-149.7c401.8-78.8,1465.5-291.5,2363.7-468.8c898.2-177.3,2115.5-417.6,2698.6-535.8c587-118.2,1103.1-212.7,1150.4-212.7c51.2,0,342.8,98.5,650,220.6c311.2,122.2,602.8,236.4,654,256.1l86.7,35.5l-7.9,3435.3L9146.4-13.3l-177.3,59.1c-98.5,31.5-386.1,130-642.1,224.6c-256.1,94.5-484.6,165.4-512.1,165.4C7787.2,431.8,7385.4,353,6920.5,258.5z M6065.6-1423.7c63-43.3,67-137.9,59.1-973.1l-11.8-925.8H4990.1H3867.4l-11.8,748.5l-7.9,752.4L4899.5-1601c583.1,122.1,1067.6,224.5,1079.4,224.5C5990.8-1372.5,6030.2-1396.1,6065.6-1423.7z M3690.1-2593.7v-748.5H2981h-709.1v606.7v606.7l386.1,67c327,59.1,992.8,197,1024.3,212.7C3686.1-1849.2,3690.1-2180.1,3690.1-2593.7z M3690.1-4220.8v-764.3l-264,51.2c-149.7,31.5-468.8,90.6-709.1,137.9l-445.2,86.7v626.4v622.4H2981h709.1V-4220.8z M6124.7-4453.2c7.9-910,4-977-59.1-977c-39.4,0-555.5,90.6-1142.5,204.9l-1075.5,204.8v752.5c0,417.6,11.8,768.2,27.6,780c15.8,15.8,524,23.6,1130.6,19.7l1107-11.8L6124.7-4453.2z">
					<p> data.lang.snapstore, <br>, " Windows Store"
				<a.platform-item rel="noreferrer" target="_blank" href="https://flathub.org/apps/details/life.bolls.bolls">
					<svg.platforms_svg id="svg" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="64" height="64" viewBox="0, 0, 400,400">
						<title> data.lang.snapstore, " Flathub"
						<g id="svgg">
							<path id="path0" d="M194.909 46.414 C 192.431 48.064,187.949 51.018,184.948 52.979 C 179.587 56.482,170.186 62.633,160.547 68.944 C 157.861 70.702,153.115 73.808,150.000 75.845 C 146.885 77.883,142.227 80.930,139.648 82.616 C 137.070 84.302,132.412 87.350,129.297 89.389 C 126.182 91.428,121.084 94.765,117.969 96.803 C 114.854 98.842,110.020 102.006,107.227 103.835 C 104.434 105.664,99.600 108.828,96.484 110.866 C 93.369 112.905,88.535 116.069,85.742 117.897 C 78.415 122.695,70.399 127.941,65.234 131.318 C 62.764 132.934,57.666 136.273,53.906 138.738 C 50.146 141.203,45.313 144.369,43.164 145.773 C 39.323 148.284,31.305 153.529,22.070 159.572 C 19.492 161.260,14.043 164.821,9.961 167.487 C 5.879 170.153,1.969 172.715,1.272 173.179 L 0.005 174.023 0.003 230.572 L -0.000 287.121 7.520 292.058 C 11.655 294.774,17.061 298.317,19.531 299.932 C 22.002 301.548,26.572 304.538,29.688 306.576 C 32.803 308.615,37.549 311.719,40.234 313.474 C 48.706 319.009,54.282 322.658,61.328 327.278 C 65.088 329.743,70.186 333.082,72.656 334.698 C 75.127 336.313,79.609 339.246,82.617 341.215 C 85.625 343.183,90.723 346.519,93.945 348.628 C 97.168 350.736,101.238 353.402,102.990 354.551 C 106.993 357.177,105.316 357.732,117.455 349.770 C 123.216 345.991,130.261 341.377,133.109 339.516 C 135.958 337.655,143.384 332.793,149.611 328.711 C 155.838 324.629,165.724 318.155,171.580 314.325 C 177.435 310.494,186.226 304.739,191.115 301.536 L 200.003 295.712 204.982 298.961 C 210.993 302.885,218.539 307.821,226.172 312.823 C 232.530 316.989,240.559 322.245,247.266 326.631 C 249.736 328.246,254.834 331.585,258.594 334.050 C 262.354 336.515,267.451 339.854,269.922 341.470 C 278.509 347.087,287.322 352.848,290.216 354.739 C 293.892 357.139,292.322 357.688,304.297 349.822 C 309.990 346.082,319.395 339.920,325.195 336.128 C 330.996 332.335,340.664 326.008,346.680 322.067 C 352.695 318.126,362.408 311.768,368.264 307.939 C 374.120 304.110,381.239 299.452,384.085 297.589 C 386.930 295.726,391.665 292.649,394.608 290.753 L 399.959 287.305 399.979 230.640 L 400.000 173.975 393.262 169.577 C 389.556 167.158,381.602 161.954,375.586 158.012 C 369.570 154.071,359.902 147.742,354.102 143.949 C 348.301 140.155,338.633 133.827,332.617 129.885 C 326.602 125.943,316.934 119.614,311.133 115.821 C 305.332 112.029,297.860 107.137,294.528 104.951 C 291.196 102.765,284.434 98.340,279.501 95.117 C 274.568 91.895,267.849 87.500,264.569 85.352 C 261.290 83.203,253.769 78.281,247.857 74.414 C 238.047 67.998,229.444 62.364,208.036 48.340 C 199.102 42.487,200.499 42.692,194.909 46.414 M245.351 86.532 C 270.144 102.757,290.481 116.184,290.544 116.368 C 290.700 116.825,200.457 175.858,199.834 175.706 C 198.904 175.481,109.349 116.681,109.460 116.369 C 109.582 116.026,199.620 57.031,200.021 57.031 C 200.159 57.031,220.557 70.307,245.351 86.532 M151.758 147.570 C 176.250 163.573,196.509 176.869,196.777 177.116 C 197.251 177.553,107.971 236.472,106.868 236.450 C 106.635 236.446,86.102 223.123,61.238 206.843 L 16.032 177.245 21.772 173.486 C 91.287 127.968,106.508 118.086,106.836 118.263 C 107.051 118.378,127.266 131.567,151.758 147.570 M339.774 148.242 C 364.076 164.141,383.912 177.308,383.854 177.504 C 383.795 177.699,363.380 191.189,338.487 207.481 L 293.227 237.102 292.173 236.422 C 270.359 222.348,202.786 177.831,202.861 177.583 C 202.918 177.393,223.335 163.904,248.231 147.608 L 293.497 117.979 294.542 118.657 C 295.117 119.031,315.471 132.344,339.774 148.242 M60.596 210.226 L 105.469 239.592 105.469 286.811 C 105.469 324.473,105.370 333.975,104.980 333.755 C 103.643 332.999,16.506 275.971,15.918 275.466 C 15.227 274.872,14.790 180.859,15.479 180.859 C 15.613 180.859,35.916 194.074,60.596 210.226 M247.809 212.695 L 292.573 241.992 292.576 289.193 C 292.577 317.277,292.435 336.340,292.224 336.263 C 292.029 336.191,271.727 322.949,247.110 306.836 L 202.350 277.539 202.347 230.339 C 202.345 202.605,202.488 183.192,202.695 183.268 C 202.888 183.340,223.189 196.582,247.809 212.695 " stroke="none" fill-rule="evenodd">
					<p> data.lang.snapstore, <br>, " Flathub"
				<a.platform-item rel="noreferrer" target="_blank" href="https://snapcraft.io/bolls">
					<svg.platforms_svg viewBox="0 0 244 244.00001" version="1.1" width="64" height="64">
						<title> data.lang.snapstore, " Snap Store"
						<path d="M 121.69531 0 A 122.00036 122.00036 0 0 0 0 122 A 122.00036 122.00036 0 0 0 122 244 A 122.00036 122.00036 0 0 0 244 122 A 122.00036 122.00036 0 0 0 122 0 A 122.00036 122.00036 0 0 0 121.69531 0 z M 38.818359 47.136719 L 135.69727 82.183594 L 135.69727 143.46094 L 38.818359 47.136719 z M 141.1875 82.183594 L 197.03125 82.183594 L 212.94531 114.07031 L 141.1875 82.183594 z M 138.96875 84.734375 L 177.34375 101.81445 L 138.96875 140.18945 L 138.96875 84.734375 z M 112.74023 125.2168 L 133.42383 145.73438 L 65.658203 213.5 L 112.74023 125.2168 z ">
					<p> data.lang.snapstore, <br>, " Snap Store"
				<a.platform-item rel="noreferrer" target="_blank" href="https://github.com/Bohooslav/bain/">
					<svg.platforms_svg height="64" viewBox="0 0 16 16" version="1.1" width="64">
						<title> data.lang.view_source
						<path fill-rule="evenodd" clip-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8C0 11.54 2.29 14.53 5.47 15.59C5.87 15.66 6.02 15.42 6.02 15.21C6.02 15.02 6.01 14.39 6.01 13.72C4 14.09 3.48 13.23 3.32 12.78C3.23 12.55 2.84 11.84 2.5 11.65C2.22 11.5 1.82 11.13 2.49 11.12C3.12 11.11 3.57 11.7 3.72 11.94C4.44 13.15 5.59 12.81 6.05 12.6C6.12 12.08 6.33 11.73 6.56 11.53C4.78 11.33 2.92 10.64 2.92 7.58C2.92 6.71 3.23 5.99 3.74 5.43C3.66 5.23 3.38 4.41 3.82 3.31C3.82 3.31 4.49 3.1 6.02 4.13C6.66 3.95 7.34 3.86 8.02 3.86C8.7 3.86 9.38 3.95 10.02 4.13C11.55 3.09 12.22 3.31 12.22 3.31C12.66 4.41 12.38 5.23 12.3 5.43C12.81 5.99 13.12 6.7 13.12 7.58C13.12 10.65 11.25 11.33 9.47 11.53C9.76 11.78 10.01 12.26 10.01 13.01C10.01 14.08 10 14.94 10 15.21C10 15.42 10.15 15.67 10.55 15.59C13.71 14.53 16 11.53 16 8C16 3.58 12.42 0 8 0Z">
					<p> data.lang.view_source

			<section#iosinstall[d:flex jc:center fld:column ai:center p:128px 0 lh: 1.5]>
				<article[p:16px]>
					<p> data.lang.ios_install, ':'
					<ul[p:32px 0 64px 32px]>
						for string in data.lang.ios_install_steps
							<li[list-style:hebrew] innerHTML=string>

				unless window.showimage
					<video$video.video controls=yes loop=yes autoplay=yes>
						<source
							src="/static/ios_install.mp4"
							type="video/mp4"
							onerror=showImage>
						<source
							src="/static/ios_install.webm"
							type="video/webm"
							onerror=showImage>
						"Your browser doesn't support HTML5 video tag."
				else
					<img.video src="/static/ios_install.mp4">


	css #downloads-container
		display: flex
		flex-wrap: wrap
		justify-content: center
		padding: 32px 0
		max-width: 1200px
		margin: auto

	css .platform-item
		display: flex
		padding: 16px
		border-radius: 20px
		text-align: center
		transform: none @hover: translateY(-4px)
		margin: 16px
		color: inherit
		cursor: pointer
		background-color: var(--btn-bg) @hover: var(--btn-bg-hover)

	css .platform-item p
		margin: auto 16px
		text-align: left
		line-height: 1.4

	css .platforms_svg
		fill: var(--text-color)
		width: 64px
		height: 64px

	css .video
		max-height: 82vh
		max-width: 100vw