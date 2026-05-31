class SiteTheme < ApplicationRecord
  DEFAULT_BRAND_NAME = "SANDU și Asociații IP Attorney".freeze
  DEFAULT_FOOTER_TEXT = "#{DEFAULT_BRAND_NAME} este o agentie de proprietate industriala specializata in marci, desene si modele, brevete de inventie, membra a CNCPIR (Camera Nationala a Consilierilor de Proprietate Industriala din Romania).".freeze
  DEFAULT_TERMS_CONTENT = <<~TEXT.freeze
    # Termeni si conditii

    Textul pentru termenii si conditiile site-ului poate fi editat din pagina de administrare.

    ## Servicii

    SANDU și Asociații IP Attorney SRL furnizeaza servicii de consultanta, asistenta si reprezentare in domeniul proprietatii industriale.

    ## Comenzi si plata

    Informatiile transmise prin formularele site-ului sunt folosite pentru pregatirea documentatiei si procesarea comenzilor.

    ## Contact

    Pentru intrebari privind serviciile sau comenzile, ne puteti contacta la contact@inregistrare-marca.com.
  TEXT
  DEFAULT_PRIVACY_POLICY_CONTENT = <<~TEXT.freeze
    # NOTĂ DE INFORMARE privind prelucrarea datelor cu caracter personal

    Efectuată de către Sandu și Asociații IP Attorney SRL, în calitate de operator de date cu caracter personal, cu sediul în str. Câmpia Libertății, nr. 42, sector 3, mun. București, Cod fiscal 45587135, prin care vă informăm despre prelucrarea datelor dumneavoastră personale, strict în vederea desfășurării profesiei de consilier de proprietate industrială și în mod special în vederea formulării de cereri, opoziții, contestații, întâmpinări, note scrise, concluzii scrise, precum și a contractului de servicii de proprietate industrială, precum și cu privire la drepturile pe care le aveți în conformitate cu REGULAMENTUL (UE) 2016/679 al Parlamentului European și al Consiliului din 27 aprilie 2016 (denumit în continuare GDPR) și legislația națională privind protecția și securitatea datelor personale, în vigoare.

    ## Scopurile și baza legală a prelucrărilor

    În conformitate cu legislaţia naţională (Legea 102/2005, modificată și completată, Legea nr. 190/2018, Legea nr. 506/2004) şi europeană (Regulamentul 2016/679/UE (GDPR), Directiva 2016/680/CE, Directiva 2002/58/CE) în vigoare, Sandu și Asociații IP Attorney SRL are obligaţia de a administra în condiţii de siguranţă şi numai pentru scopurile specificate, datele personale care îi sunt furnizate.

    Sandu și Asociații IP Attorney SRL prelucrează datele dumneavoastră personale în conformitate cu prevederile GDPR, în calitate de operator, în conformitate cu prevederile specifice aplicabile, pentru derularea următoarelor activități:

    1. Consultaţii cu privire la Mărci, Design, Invenții;
    2. Asistarea şi reprezentarea clienţilor în fața OSIM, EUIPO, OMPI ți a altor persoane fizice și juridice, în legătură cu drepturile de proprietate industrială;
    3. Formularea de cereri, opoziții, întâmpinări, contestații, note scrise, concluzii scrise, memorii, ș.a. în interesul clienților;

    Dacă nu sunteți de acord cu furnizarea datelor personale, Sandu și Asociații IP Attorney SRL nu poate să efectueze activitățile legale mai sus menționate.

    ## Temeiul legal al prelucrării datelor

    Datele dumneavoastră cu caracter personal sunt prelucrate pentru îndeplinirea obligațiilor legale care îi revin operatorului, conform articolului 6 alin. 1 literele b) și c) din GDPR.

    În măsura în care sunt necesare categorii speciale de date cu caracter personal, operatorul va solicita consimțământul dvs. în conformitate cu prevederile art. 9 alin. (2) lit. (a) din GDPR.

    Legislația care guvernează, în principal, activitățile derulate de operator sunt următoarele:

    - Regulamentul 2016/679/UE, Directiva 2016/680/CE, Directiva 2002/58/CE
    - Legea 102/2005, modificată și completată, Legea nr. 190/2018, Legea nr. 506/2004, Legea nr. 544/2004, Ordonanța Guvernului nr. 27/2002
    - Codul de procedură civilă

    ## Tipuri de date cu caracter personal pe care le prelucrăm

    Politica privind protecția și securitatea datelor personale a operatorului este de a colecta numai datele personale necesare în scopurile menționate și de a solicita persoanelor vizate să ne comunice numai acele date cu caracter personal strict necesare îndeplinirii acestor scopuri.

    Categoriile de date personale (clasice sau digitale) supuse prelucrărilor la nivelul operatorului sunt următoarele: nume, prenume, semnătura, detalii de contact - număr de telefon personal, adresă de email, adresa de domiciliu/reședință, etc., adresă poștală, serie și număr CI/BI, CNP.

    Ne rezervăm dreptul de a solicita alte date necesare pentru îndeplinirea atribuțiilor legale, strict în conformitate cu prevederile legale.

    ## Sursa datelor cu caracter personal

    Operatorul colectează date personale direct de la dumneavoastră sau de la terți (cum ar fi alte instituții ori entități care se adresează operatorului ori alte persoane vizate) sau din documente publice.

    În cazul în care trebuie să prelucrăm date cu caracter personal obținute de la terți persoane juridice, aceștia din urmă au obligația de a vă furniza informațiile necesare cu privire la utilizarea datelor cu caracter personal transmise.

    ## Categorii de destinatari ai datelor cu caracter personal

    Datele dumneavoastră personale sunt destinate utilizării de către operator şi sunt comunicate următorilor destinatari, dacă este cazul: CNCPIR, OSIM, EUIPO, OMPI, alte instituții/autorități centrale și locale în vederea exercitării atribuțiilor specifice profesiei de avocat, instanțelor de judecată în vederea formulării de acțiuni și reprezentării în instanță.

    Dezvăluirea datelor către terți se face conform prevederilor legale pentru categoriile de destinatari precizați anterior.

    ## Perioada de stocare a datelor personale

    Datele dumneavoastră personale sunt stocate pe perioada necesară efectuării tuturor demersurilor întreprinse pentru susținerea activităților legale ale operatorului, după care vor fi arhivate potrivit legislației aplicabile.

    ## Drepturile dumneavoastră și modul de exercitare al acestora

    Conform prevederilor legale aplicabile, beneficiaţi de dreptul de acces, dreptul la rectificare, dreptul la ştergerea datelor, dreptul la restricţionarea prelucrării, dreptul la portabilitatea datelor, dreptul la opoziţie şi procesul decizional individual automatizat.

    Pentru exercitarea drepturilor dvs. vă rugăm să ne contactați direct la adresa de e-mail: avocat@dan-sandu.ro sau în scris la sediul operatorului.

    ## Prelucrările de date speciale sau întemeiate pe consimțământ

    Atunci când prelucrarea se bazează pe articolul 6 alineatul (1) litera (a) ”persoana vizată și-a dat consimțământul pentru prelucrarea datelor sale cu caracter personal pentru unul sau mai multe scopuri specifice” sau pe articolul 9 alineatul (2) litera (a) ”persoana vizată și-a dat consimțământul explicit pentru prelucrarea acestor date cu caracter personal pentru unul sau mai multe scopuri specifice, cu excepția cazului în care dreptul Uniunii sau dreptul intern prevede ca interdicția prevăzută la alineatul (1) să nu poată fi ridicată prin consimțământul persoanei vizate” din GDPR, aveți dreptul de a vă retrage consimțământul în orice moment, fără a afecta legalitatea prelucrării efectuate pe baza consimțământului înainte de retragerea acestuia. Astfel, puteți modifica sau elimina consimțământul în orice moment, și vom acționa imediat în consecință, cu excepția cazului în care există un motiv legal sau un interes legitim pentru a nu face acest lucru.
  TEXT

  DEFAULTS = {
    primary_color: "#00add9",
    primary_dark_color: "#00add9",
    brand_color: "#013ebe",
    text_color: "#1f1d1a",
    muted_color: "#68635c",
    line_color: "#ded8cf",
    background_color: "#ffffff",
    font_family: "Montserrat",
    brand_name: DEFAULT_BRAND_NAME
  }.freeze

  validates :primary_color, :primary_dark_color, :brand_color, :text_color,
    :muted_color, :line_color, :background_color, :font_family, :brand_name, presence: true

  def self.current
    first_or_create!(DEFAULTS)
  end

  def as_json(*)
    {
      primary_color: primary_color,
      primary_dark_color: primary_dark_color,
      brand_color: brand_color,
      text_color: text_color,
      muted_color: muted_color,
      line_color: line_color,
      background_color: background_color,
      font_family: font_family,
      brand_name: brand_name.presence || DEFAULT_BRAND_NAME,
      hero_image_key: hero_image_key,
      logo_image_key: logo_image_key,
      footer_logo_image_key: footer_logo_image_key,
      footer_text: footer_text.presence || DEFAULT_FOOTER_TEXT,
      terms_content: terms_content.presence || DEFAULT_TERMS_CONTENT,
      privacy_policy_content: privacy_policy_content.presence || DEFAULT_PRIVACY_POLICY_CONTENT
    }
  end
end
