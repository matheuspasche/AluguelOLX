import pandas as pd
from geopy.geocoders import Nominatim

Dados = r.Dados

geolocator = Nominatim(user_agent="geolocalização")

Dados['CEP'] = Dados['CEP'].apply(lambda x: str(x))
Dados['CEP'] = Dados['CEP'].apply(lambda x: x[:5] + "-" + x[5:])
Dados['Logradouro'] = Dados['Logradouro'].apply(lambda x:  str(x).split(" - ")[0])

Dados['Endereco'] = Dados['Bairro']+ ", " + Dados['Município'] + ", " + Dados['CEP']
Dados['latitude'] = Dados['Endereco'].apply(lambda x: geolocator.geocode(x).latitude if geolocator.geocode(x) is not None else None)
Dados['longitude'] = Dados['Endereco'].apply(lambda x: geolocator.geocode(x).longitude if geolocator.geocode(x) is not None else None)

