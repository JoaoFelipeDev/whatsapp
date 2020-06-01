import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  String _idUsuarioLogado;
  String _emailUsuarioLogado;

  
  Future <List<Usuario>> _recuperarContatos () async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot = await db.collection("usuario")
    .getDocuments();

    List <Usuario> listaUsuario = List();

    for( DocumentSnapshot item in querySnapshot.documents){

      var dados = item.data;

      if(dados["email"] == _emailUsuarioLogado) continue;

    

      Usuario usuario = Usuario();
      usuario.idUsuario = item.documentID;
      usuario.email = dados ["email"];
      usuario.nome = dados ["nome"];
      usuario.urlImagem = dados ["urlImagem"];

      listaUsuario.add(usuario);


    }
    return listaUsuario;

  }
   _recuperarDadosUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email;

    
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot){
          switch(snapshot.connectionState ){
             
             case ConnectionState.none:
             case ConnectionState.waiting:
             return Center(
               child: Column(
                 children: <Widget>[
                   Text("Carregando Contatos"),
                   CircularProgressIndicator()
                 ],
               ),
             );
             break;
             case ConnectionState.active:
             case ConnectionState.done:
             return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (context, indice){

         List<Usuario> listaItem = snapshot.data;
         Usuario usuario = listaItem [indice];

          return ListTile(
              onTap: (){
                Navigator.pushNamed(
                    context,
                    "/mensagens",
                  arguments: usuario
                );
              },
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: 
               usuario.urlImagem != null
               ? NetworkImage( usuario.urlImagem )
               : null
            ),
            title: Text(
              usuario.nome,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
          );

        }
    );
      

     
             
             break;
          }
  },
    );
}
}
