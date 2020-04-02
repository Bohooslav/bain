import {Bible} from './components/Bible'
import {State} from './components/state'

let Data = State.new

Imba.mount <Bible[Data]>

tag Notification < section
	def render
		<self>
			if @data.notification
				<p id="notification"> @data.notification

Imba.mount <Notification[Data]>