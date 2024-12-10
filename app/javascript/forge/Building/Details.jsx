import React from 'react'
import SimpleFormat from '../SimpleFormat'

export const Details = (building) => (
    <>
        <h5>
            <a href={`/buildings/${building.id}`} target="_blank"
               title="Open building record in new tab" rel="noreferrer">
                <SimpleFormat text={building.street_address} />
            </a>
        </h5>

        {(building.year_earliest || building.year_latest) && (
            <dl className="mb-0">
                <dt>Years</dt>
                <dd>
                    {building.year_earliest && `Built in ${building.year_earliest}.`}
                    {building.year_latest ? ` Torn down in ${building.year_latest}.` : ' Still standing.'}
                </dd>
            </dl>
        )}
        {building.architects && building.architects.length && (
            <dl className="mb-0">
                <dt>Architects</dt>
                <dd>{building.architects}</dd>
            </dl>
        )}
        <dl>
            <dt>Type</dt>
            <dd>{building.type || 'Not specified'}</dd>
            {(building.stories || building.frame || building.lining) && (
                <>
                <dt>Construction</dt>
                <dd>
                    {building.stories && `${building.stories}-story `}
                    {building.frame && `${building.frame} structure`}
                    {building.lining && ` with ${building.lining} lining`}
                    .
                </dd>
                </>
            )}
        </dl>
        {building.photo && (
            <div>
                <picture>
                    <source srcSet={`/photos/${building.photo}/15/phone.jpg`}
                            media="(max-width:480px)"/>
                    <source srcSet={`/photos/${building.photo}/15/tablet.jpg`}
                            media="(min-width:481px) and (max-width:1024px)"/>
                    <source srcSet={`/photos/${building.photo}/15/desktop.jpg`}
                            media="(min-width:1025px)"/>
                    <img className="img-responsive img-thumbnail" alt="Building photo" />
                </picture>
            </div>
        )}
    </>
)
