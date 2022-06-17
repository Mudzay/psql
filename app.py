from flask import Flask, render_template, request, redirect, url_for
import psycopg2

app = Flask(__name__)

conn = psycopg2.connect("dbname=db_g218 user=g218 password=C9C6_65fdf8 host=psql01.mikr.us")

cur = conn.cursor()

@app.route('/')
def index():
    return render_template('index.html')

def dane(nazwa):
    '''
        Funkcja służy do zwracania wszystkich wierszy oraz nazw kolumn z wybranej tabeli.
    '''
    cur.execute(f"SELECT * FROM {nazwa} ORDER BY id")
    rows = cur.fetchall()
    colnames = [desc[0] for desc in cur.description]
    return (rows, colnames)

def jeden(nazwa, id):
    '''
        Funkcja służy do zwracania jednego wiersza o podanym id z wybranej tabeli oraz nazw kolumn.
    '''
    cur.execute(f"SELECT * FROM {nazwa} WHERE id = {id}")
    row = cur.fetchone()
    colnames = [desc[0] for desc in cur.description]
    return (row, colnames)

@app.route('/magazyn')
def magazyn():
    rows, colnames = dane("pokaz_mi_swoje_towary")
    return render_template('magazyn.html', rows=rows, colnames=colnames)


def katgat():
    '''
        Funkcja służy do zawracania kategorii, gatunków oraz ich id.
        Stworzyłem ją, ponieważ używam tego samego kodu wiele razy.
    '''
    cur.execute("SELECT * FROM kategorie")
    kat = cur.fetchall()
    cur.execute("SELECT * FROM gatunki")
    gat = cur.fetchall()
    return (kat, gat)


@app.route('/editmagazyn', methods=['GET', 'POST'])
def editmagazyn():
    if request.method == 'POST':
        id = request.form['id']
        nazwa = request.form['nazwa']
        kat = request.form['kat']
        gat = request.form['gat']
        ilosc = request.form['ilosc']
        cena = request.form['cena']
        cur.execute("UPDATE magazyn SET nazwa = '%s', kategoria = %s, gatunek = %s, stan = %s, cena = %s WHERE id = %s" % (nazwa, kat, gat, ilosc, cena, id))
        conn.commit()
        return redirect(url_for('magazyn'))
    else:
        id = request.args.get('id', default=None)
        if id is None:
            return redirect(url_for('magazyn'))
        row, colnames = jeden("pokaz_mi_swoje_towary", id)
        kat, gat = katgat()
        return render_template('editmagazyn.html', row=row, colnames=colnames, kat=kat, gat=gat)

@app.route('/zamowienia')
def zamowienia():
    rows, colnames = dane('wyswietl_zamowienia')
    return render_template('zamowienia.html', rows=rows, colnames=colnames)

@app.route('/delzam', methods=['POST'])
def delzam():
    id = request.form['id']
    cur.execute("DELETE FROM zamowienie WHERE id = %s", (id,))
    conn.commit()
    return redirect(url_for('zamowienia'))

@app.route('/dodaj', methods=['GET', 'POST'])
def dodaj():
    if request.method == 'POST':
        nazwa = request.form['nazwa']
        kat = request.form['kat']
        gat = request.form['gat']
        ilosc = request.form['ilosc']
        cena = request.form['cena']
        cur.execute("INSERT INTO magazyn (nazwa, kategoria, gatunek, stan, cena) VALUES ('%s', %s, %s, %s, %s)" % (nazwa, kat, gat, ilosc, cena))
        conn.commit()
        return redirect(url_for('magazyn'))
    else:
        kat, gat = katgat()
        return render_template('dodaj.html', kat=kat, gat=gat)

@app.route('/klienci')
def klienci():
    rows, colnames = dane('klient')
    return render_template('klienci.html', rows=rows, colnames=colnames)

@app.route('/klientedit', methods=['GET', 'POST'])
def klientedit():
    if request.method == 'POST':
        id = request.form['id']
        imie = request.form['imie']
        nazwisko = request.form['nazwisko']

        cur.execute("UPDATE klient SET imie = '%s', nazwisko = '%s' WHERE id = %s" % (imie, nazwisko, id))
        conn.commit()
        return redirect(url_for('klienci'))
    else:
        id = request.args.get('id', default=None)
        if id is None:
            return redirect(url_for('klienci'))
        cur.execute("SELECT * FROM klient WHERE id = %s", (id,))
        row, colnames = jeden("klient", id)
        return render_template('klientedit.html', row=row, colnames=colnames)

@app.route('/klientdel', methods=['GET', 'POST'])
def klientdel():
    id = request.args.get('id', default=None)
    if id is None:
        return redirect(url_for('klienci'))
    cur.execute("DELETE FROM klient WHERE id = %s", (id,))
    conn.commit()
    return redirect(url_for('klienci'))

@app.route('/usun', methods=['GET', 'POST'])
def usun():
    id = request.args.get('id', default=None)
    if id is None:
        return redirect(url_for('magazyn'))
    cur.execute("DELETE FROM magazyn WHERE id = %s", (id,))
    conn.commit()
    return redirect(url_for('magazyn'))

@app.route('/klientdod', methods=['GET', 'POST'])
def klientdod():
    if request.method == 'POST':
        imie = request.form['imie']
        nazwisko = request.form['nazwisko']
        cur.execute("INSERT INTO klient (imie, nazwisko) VALUES ('%s', '%s')" % (imie, nazwisko))
        conn.commit()
        return redirect(url_for('klienci'))
    else:
        return render_template('klientdod.html')

@app.route('/zamowienia_klienta')
def zamowienia_klienta():
    id = request.args.get('id', default=None)
    if id is None:
        return redirect(url_for('klienci'))
    cur.execute("SELECT id, nazwa, ile, suma, kiedy FROM zamowienia_klienta(%s)", (id,))
    rows = cur.fetchall()
    colnames = [desc[0] for desc in cur.description]
    return render_template('zamowienia_klienta.html', rows=rows, colnames=colnames, id=id)

def ktoc():
    '''
        Funkcja zwraca listę klientów oraz towarów.
    '''
    cur.execute("SELECT * FROM _klienci")
    kto = cur.fetchall()
    cur.execute("SELECT * FROM _towar")
    co = cur.fetchall()
    return kto, co

def ktoc1(id):
    cur.execute("SELECT * FROM _klienci WHERE id = %s" % (id,))
    kto = cur.fetchone()
    cur.execute("SELECT * FROM _towar WHERE m.id = %s" % (id,))
    co = cur.fetchone()
    return kto, co

@app.route('/nowe_zamowienie', methods=['GET', 'POST'])
def nowe_zamowienie():
    if request.method == 'POST':
        kto = request.form['kto']
        co = request.form['co']
        ile = request.form['ile']
        cur.execute("INSERT INTO zamowienie (kto, co, ile) VALUES ('%s', '%s', %s)" % (kto, co, ile))
        conn.commit()
        return redirect(url_for('zamowienia'))
    else:
        kto, co = ktoc()
        return render_template('nowe_zamowienie.html', kto=kto, co=co)

@app.route('/kategorie', methods=['GET', 'POST'])
def kategorie():
    if request.method == 'POST':
        kat = request.form['kat']
        try:
            cur.execute("INSERT INTO kategorie (kat) VALUES ('%s')" % (kat,))
            conn.commit()
        except:
            conn.rollback()
        return redirect(url_for('kategorie'))
    else:
        cur.execute("SELECT id, kat FROM kategorie")
        rows = cur.fetchall()
        colnames = [desc[0] for desc in cur.description]
        return render_template('kategorie.html', rows=rows, colnames=colnames)

@app.route('/gatunki', methods=['GET', 'POST'])
def gatunki():
    if request.method == 'POST':
        gat = request.form['gat']
        try:
            cur.execute("INSERT INTO gatunki (nazwa) VALUES ('%s')" % (gat,))
            conn.commit()
        except:
            conn.rollback()
        return redirect(url_for('gatunki'))
    else:
        cur.execute("SELECT id, nazwa FROM gatunki")
        rows = cur.fetchall()
        colnames = [desc[0] for desc in cur.description]
        return render_template('gatunki.html', rows=rows, colnames=colnames)