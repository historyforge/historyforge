import React from "react";
import { Row, Col } from "reactstrap";

const Residents = ({ buildingId, residents, years }) => (
    years.map(year => residents[year] && (
        <div key={year} className="mt-4">
            <h5 className="mb-3">Residents in {year}</h5>
            {residents[year].map((family, index) => (
                <div key={`family-${index}`}>
                    {family.map((person, personIndex) => (
                        <React.Fragment key={`person-${buildingId}-${personIndex}`}>
                            <Resident person={person} year={year} />
                            <hr />
                        </React.Fragment>
                    ))}
                </div>
            ))}
            {/* <table className="table table-condensed">
                <thead>
                <tr>
                    <th>Name</th>
                    <th>Relation</th>
                    <th>Age</th>
                    <th>Race</th>
                    <th>Sex</th>
                    <th>Occupation</th>
                </tr>
                </thead>
                <tbody key={year}>
                {residents[year].map(family => (
                    family.map(person => (
                        <tr key={person.id}>
                            <td><a href={`/census/${year}/${person.id}`}>{person.name}</a></td>
                            <td>{person.relation_to_head}</td>
                            <td>{person.age}</td>
                            <td>{person.race}</td>
                            <td>{person.sex}</td>
                            <td>{person.occupation}</td>
                        </tr>
                    ))
                ))}
                </tbody>
            </table> */}
        </div>
    ))
)

export default Residents

const Resident = ({person, year}) => {
    let occupation = person.occupation;
    if (person.occupation === "None") {
        occupation = null;
    }
    if (person.relation_to_head === person.occupation) {
        occupation = null;
    }
    return (
        <Row>
            <Col size={7} sm={6}>
                <a href={`/census/${year}/${person.id}`} target="_blank">{person.name}</a>
            </Col>
            <Col size={5} sm={6}>
                {person.relation_to_head}
            </Col>
            <Col size={6} sm={6}>
                Age {person.age} - {person.race} - {person.sex}
            </Col>
            {occupation && <Col size={6} sm={6}>{occupation}</Col>}
        </Row>
    )
}