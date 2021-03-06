{***************************************************************************}
{                                                                           }
{           eInvoice4D - (Fatturazione Elettronica per Delphi)              }
{                                                                           }
{           Copyright (C) 2018  Delphi Force                                }
{                                                                           }
{           info@delphiforce.it                                             }
{           https://github.com/delphiforce/eInvoice4D.git                   }
{                                                                  	        }
{           Delphi Force Team                                      	        }
{             Antonio Polito                                                }
{             Carlo Narcisi                                                 }
{             Fabio Codebue                                                 }
{             Marco Mottadelli                                              }
{             Maurizio del Magno                                            }
{             Omar Bossoni                                                  }
{             Thomas Ranzetti                                               }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  This file is part of eInvoice4D                                          }
{                                                                           }
{  Licensed under the GNU Lesser General Public License, Version 3;         }
{  you may not use this file except in compliance with the License.         }
{                                                                           }
{  eInvoice4D is free software: you can redistribute it and/or modify       }
{  it under the terms of the GNU Lesser General Public License as published }
{  by the Free Software Foundation, either version 3 of the License, or     }
{  (at your option) any later version.                                      }
{                                                                           }
{  eInvoice4D is distributed in the hope that it will be useful,            }
{  but WITHOUT ANY WARRANTY; without even the implied warranty of           }
{  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            }
{  GNU Lesser General Public License for more details.                      }
{                                                                           }
{  You should have received a copy of the GNU Lesser General Public License }
{  along with eInvoice4D.  If not, see <http://www.gnu.org/licenses/>.      }
{                                                                           }
{***************************************************************************}
unit DForce.ei.Invoice.Ex;

interface

uses DForce.ei.Invoice.Base, DForce.ei.Invoice.Interfaces, System.Classes,
  DForce.ei.Response.Interfaces, DForce.ei.GenericCollection,
  DForce.ei.Validation.Interfaces;

type

  TeiInvoiceEx = class(TXMLFatturaElettronicaType, IeiInvoiceEx)
  private
    FReference: string;
    FValidationResultCollection: IeiValidationResultCollectionInt;
    procedure InternalSaveToStream(const AStream: TStream; const AInvoice: String);
  protected
    function ToString: String; reintroduce;
    function ToStringBase64: String;
    function Validate: boolean;
    function ValidationResultCollection: IeiValidationResultCollectionInt;
    procedure SaveToFile(const AFileName: String);
    procedure SaveToStream(const AStream: TStream);
    procedure SaveToStreamBase64(const AStream: TStream);
    procedure FillWithSampleData;
    // Reference
    procedure SetReference(const AValue: string);
    function GetReference: string;
  end;

  TeiInvoiceCollectionEx = TeiCollection<IeiInvoiceEx>;

  TeiInvoiceIDCollectionEx = TeiCollection<string>;

implementation

uses Xml.XMLDoc, System.NetEncoding, DForce.ei.Exception, System.SysUtils,
  DForce.ei, DForce.ei.Utils, DForce.ei.Validation.Engine;

{ TeiInvoiceEx }

procedure TeiInvoiceEx.FillWithSampleData;
begin
  TeiUtils.FillInvoiceSample(Self);
end;

function TeiInvoiceEx.GetReference: string;
begin
  result := FReference;
end;

procedure TeiInvoiceEx.InternalSaveToStream(const AStream: TStream; const AInvoice: String);
var
  LStringStream: TStringStream;
begin
  // Check the stream
  if not Assigned(AStream) then
    raise eiGenericException.Create('"AStream" parameter not assigned');
  // Save invoice into the stream
  LStringStream := TStringStream.Create(AInvoice);
  try
    AStream.CopyFrom(LStringStream, 0);
  finally
    LStringStream.Free;
  end;
end;

procedure TeiInvoiceEx.SaveToFile(const AFileName: String);
var
  LFileStream: TFileStream;
begin
  if FileExists(AFileName) then
    raise eiGenericException.Create(Format('File "%s" already exists', [AFileName]));
  LFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    InternalSaveToStream(LFileStream, ToString);
  finally
    LFileStream.Free;
  end;
end;

procedure TeiInvoiceEx.SaveToStream(const AStream: TStream);
begin
  InternalSaveToStream(AStream, ToString);
end;

procedure TeiInvoiceEx.SaveToStreamBase64(const AStream: TStream);
begin
  InternalSaveToStream(AStream, ToStringBase64);
end;

procedure TeiInvoiceEx.SetReference(const AValue: string);
begin
  FReference := AValue;
end;

function TeiInvoiceEx.ToString: String;
var
  Lxml: TStringList;
begin
  Lxml := TStringList.Create;
  try
    Lxml.Text := FormatXMLData(Self.GetXML);

    // AGGIUNTO V 1.2 - INIZIO
    Lxml[0] := '<?xml version="1.0" encoding="UTF-8"?>';
    Lxml.Insert(1, '<p:FatturaElettronica versione="' + Self.FatturaElettronicaHeader.DatiTrasmissione.FormatoTrasmissione + '"');
    Lxml.Insert(2, 'xmlns:ds="http://www.w3.org/2000/09/xmldsig#"');
    Lxml.Insert(3, 'xmlns:p="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2"');
    Lxml.Insert(4, 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
    Lxml.Insert(5,
      'xsi:schemaLocation="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2 http://www.fatturapa.gov.it/export/fatturazione/sdi/fatturapa/v1.2/Schema_del_file_xml_FatturaPA_versione_1.2.xsd">');
    // AGGIUNTO V 1.2 - FINE

    // Se abilitato aggiunge il riferimento al file XSL
    // if AggiungiXSL then
    // Lxml.Insert(1, '<?Lxml-stylesheet type="text/xsl" href="fatturapa_v1.2.xsl"?>');
    // Aggiunge "p:" alla fine nel Tag di chiusura
    Lxml[Lxml.Count - 1] := '</p:FatturaElettronica>';
    result := String(Lxml.Text).Trim;
  finally
    Lxml.Free;
  end;
end;

function TeiInvoiceEx.ToStringBase64: String;
begin
  result := TNetEncoding.Base64.Encode(ToString);
end;

function TeiInvoiceEx.Validate: boolean;
begin
  FValidationResultCollection := TeiValidationEngine.Validate(Self);
  result := (FValidationResultCollection.Count = 0);
end;

function TeiInvoiceEx.ValidationResultCollection: IeiValidationResultCollectionInt;
begin
  if not Assigned(FValidationResultCollection) then
    Validate;
  result := FValidationResultCollection;
end;

end.
