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
unit DForce.ei.Validation.Factory;

interface

uses DForce.ei.Validation.Interfaces;

type

  TeiValidationFactory = class
  public
    class function NewValidationResultCollection: IeiValidationResultCollectionInt;
    class function NewValidationResult(const AInfo, ACode, ADescription: string; const ASeverity: TeiSeverityType): IeiValidationResultInt;
  end;

implementation

uses
  DForce.ei.Validation.ValidationResult;

{ TeiValidationFactory }

class function TeiValidationFactory.NewValidationResult(const AInfo, ACode, ADescription: string; const ASeverity: TeiSeverityType)
  : IeiValidationResultInt;
begin
  result := TeiValidationResult.Create(AInfo, ACode, ADescription, ASeverity);
end;

class function TeiValidationFactory.NewValidationResultCollection: IeiValidationResultCollectionInt;
begin
  result := TeiValidationResultCollection.Create;
end;

end.
