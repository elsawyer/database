handler = Gmaps.build('Google');
handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
  console.log("in map stuff")
  handler.bounds.extendWith(markers);
  handler.fitMapToBounds();
});