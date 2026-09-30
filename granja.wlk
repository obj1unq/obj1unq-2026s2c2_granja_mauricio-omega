import wollok.game.*

object femenino{
	method prefijo() {
		return "f"
	}
	method otro() {
		return masculino
	}
}
object masculino{
	method prefijo() {
		return "m"
	}
	method otro() {
		return femenino
	}
}



object personaje {
	var property genero = femenino
	var property position = game.center()
	const propiedad = granja
	var property oro = 0
	
	method  image() {
		return genero.prefijo() + "-player-" + self.estado() + ".png"
	} 
	method estado() {
		return if (self.estaSobreAlgo())  "abajo" else "normal" 
	}
	method estaSobreAlgo() {
		return not game.colliders(self).isEmpty()
	}
	
	method cosechasParaVender() = granja.cantidadDeCosechasParaVender()
	
	method oroGanadoPorVenderTodo() = granja.oroObtenidoPorCultivosCosechados()
	
	method venderTodo(){
		oro += self.oroGanadoPorVenderTodo()
		granja.venderLosCultivosCosechados()
	}
	
	method text() = "Oro: " + oro
	
	method cambiarGenero() {
		genero = genero.otro()
	}
	
	method decirCosechasParaVender() {
		game.say(self, "Tengo " + self.cosechasParaVender() + " plantas para vender por " + self.oroGanadoPorVenderTodo() + " monedas")
	}


	method plantar(cultivo) {
		propiedad.plantar(cultivo, position)
	} 
	
	method regarPlanta(){
		granja.regarCultivo(position)
	}
	
	method cosecharPlanta(){
		granja.cosecharCultivo(position)
	}
}

object mercado {
	const property position = game.at(8,8)
	const property image = "mercado.png"
}

object granja {
	const property cultivos = #{}
	const property cultivosCosechados = []
	const mercadoDeCultivo = mercado
	
	method plantar(cultivo, position) {
		self.validarPlantar(cultivo, position)
		cultivo.position(position)
		cultivos.add(cultivo)
		game.addVisual(cultivo)
	}
	method validarPlantar(cultivo, position) {
		if (not self.puedePlantar(cultivo, position)) {
			self.error("No se puede plantar")
		}
	}
	
	method regarCultivo(position){
		self.validarRegar(position)
		
		self.cultivoEn(position).regado()
	}
	
	method validarRegar(position) {
		if (! self.hayCultivo(position)) {
			self.error("no tengo nada para regar")
		}
	}
	
	
	method cosecharCultivo(position){
		self.validarCosecha(position)
		
		const cultivo = self.cultivoEn(position)
	
		cultivosCosechados.add(cultivo)
		cultivos.remove(cultivo)
		cultivo.cosechado()
	}
	
	method validarCosecha(position){
		if (!self.hayCultivo(position)){
			self.error("Aqui no hay cultivo para cosechar")
		}
		if (!self.cultivoEn(position).sePuedeCosechar()){
			self.error("Este cultivo no esta listo para cosecharse")
		}
	}
	
	method estaOcupada(position) = self.hayCultivo(position) || mercadoDeCultivo.position() == position
	
	method puedePlantar(cultivo, position) {
		return not cultivos.contains(cultivo) and not self.estaOcupada(position)
	}
	method hayCultivo(position) {
		return cultivos.any({cultivo => cultivo.position() == position})
	}
	
	method cultivoEn(position) {
		return cultivos.find({ cultivo => cultivo.position() == position })
	}
	
	method venderLosCultivosCosechados(){
		cultivosCosechados.clear()
	}
	
	method oroObtenidoPorCultivosCosechados() = cultivosCosechados.sum({cultivo => cultivo.precioEnOro()})
	
	method cantidadDeCosechasParaVender() = cultivosCosechados.size()
}

object maiz{
	var property estado = maizBebe
	var property position = game.at(0,0)

	method image() {
		return "maiz_" +estado.nombre() +".png"
	}
	
	method sePuedeCosechar() = estado.listoParaCosechar()
	
	method precioEnOro() = 150
	
	method regado(){
		estado = estado.crecer()
	}
	
	method cosechado() {
		game.removeVisual(self)
	}
}
//======================= Estados del Maiz 
object maizBebe{
	method nombre() = "bebe"
	method crecer() = maizAdulto
	method listoParaCosechar() = false
}
object maizAdulto{
	method nombre() = "adulto"
	method crecer() = self
	method listoParaCosechar() = true
}
//Aca finaliza======================= 


object trigo{
	var estado = trigo0
	var property position = game.at(0,0)
	
	method image() = "trigo_"+ estado.nombre() +".png"
	
	method sePuedeCosechar() = estado.listoParaCosechar()
	
	method precioEnOro() = (estado.etapa() - 1) * 100
	
	method regado(){
		estado = estado.crecer()
	}
	
	method cosechado() {
		game.removeVisual(self)
	}
}
//======================= Estados del Trigo 
object trigo0 {
	method nombre() = "0"
	method crecer() = trigo1
	method listoParaCosechar() = false
}
object trigo1 {
	method nombre() = "1"
	method crecer() = trigo2
	method listoParaCosechar() = false
}
object trigo2 {
	method nombre() = "2"
	method crecer() = trigo3
	method listoParaCosechar() = true
	method etapa() = 2
}
object trigo3 {
	method nombre() = "3"
	method crecer() = trigo0
	method listoParaCosechar() = true
	method etapa() = 3
}
//Aca finaliza======================= 


object tomaco {
	var property position = game.at(0, 0)
	const cultivos = granja

	method image() = "tomaco.png"	

	method sePuedeCosechar() = true

	method precioEnOro() = 80

	method regado() {
		if (!cultivos.estaOcupada(self.posicionSiguiente())) {
			position = self.posicionSiguiente()
		}
	}

	method posicionSiguiente() {
		return
			if (position.y() == game.height() - 1) {
				game.at(position.x(), 0)
			} else {
				game.at(position.x(), position.y() + 1)
			}
	}
	
	method cosechado() {
		game.removeVisual(self)
	}
}
//======================= Estados del Tomaco =========================
object baby{
	method nombre() = "o_baby"
}
object hechaderecha{
	method nombre() = "o"
}
//Aca finaliza======================= 